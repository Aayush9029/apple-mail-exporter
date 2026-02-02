import Foundation

public struct MailConfig {
    public let mailBase: URL
    public let mailDir: URL
    public let envelopeDB: URL
}

public func findMailVersionDir(base: URL) throws -> URL {
    let fm = FileManager.default
    guard fm.fileExists(atPath: base.path) else {
        throw MailError.noMailDirectory(base.path)
    }

    let contents = try fm.contentsOfDirectory(at: base, includingPropertiesForKeys: nil)
    // Match V followed by digits, pick highest number
    let vDirPattern = try NSRegularExpression(pattern: #"^V(\d+)$"#)
    let candidates = contents
        .filter { url in
            let name = url.lastPathComponent
            let range = NSRange(name.startIndex..., in: name)
            return vDirPattern.firstMatch(in: name, range: range) != nil
        }
        .sorted { a, b in
            let aNum = Int(a.lastPathComponent.dropFirst()) ?? 0
            let bNum = Int(b.lastPathComponent.dropFirst()) ?? 0
            return aNum > bNum
        }

    guard let best = candidates.first else {
        throw MailError.noVersionDir(base.path)
    }
    return best
}

public func resolveMailConfig(mailDir: URL? = nil, mailBase: URL? = nil) throws -> MailConfig {
    let envDir = ProcessInfo.processInfo.environment["APPLE_MAIL_DIR"].map {
        URL(fileURLWithPath: ($0 as NSString).expandingTildeInPath)
    }
    let envBase = ProcessInfo.processInfo.environment["APPLE_MAIL_BASE"].map {
        URL(fileURLWithPath: ($0 as NSString).expandingTildeInPath)
    }

    let resolvedBase = mailBase ?? envBase ?? FileManager.default.homeDirectoryForCurrentUser
        .appendingPathComponent("Library/Mail")
    let resolvedDir = try mailDir ?? envDir ?? findMailVersionDir(base: resolvedBase)
    let envelopeDB = resolvedDir.appendingPathComponent("MailData/Envelope Index")

    return MailConfig(mailBase: resolvedBase, mailDir: resolvedDir, envelopeDB: envelopeDB)
}

public enum MailError: LocalizedError {
    case noMailDirectory(String)
    case noVersionDir(String)
    case databaseOpenFailed(String)
    case databaseBusy
    case databaseError(String)
    case noFullDiskAccess

    public var errorDescription: String? {
        switch self {
        case .noMailDirectory(let path):
            return "Apple Mail directory not found: \(path)"
        case .noVersionDir(let path):
            return "No Apple Mail data found (no V* directory in \(path)). Is Mail configured on this Mac?"
        case .databaseOpenFailed(let detail):
            return "Cannot open database. \(detail)"
        case .databaseBusy:
            return "Database is locked — Apple Mail may be performing a sync. Try again in a moment."
        case .databaseError(let msg):
            return "Database error: \(msg)"
        case .noFullDiskAccess:
            return "Cannot open database. Ensure Full Disk Access is granted to your terminal in System Settings > Privacy & Security > Full Disk Access."
        }
    }
}

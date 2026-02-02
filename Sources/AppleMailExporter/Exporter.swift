import Foundation

public struct ExportResult {
    public let path: URL
    public let record: EmailRecord
}

public func resolveOutputDir(_ output: String) throws -> URL {
    let path: URL
    if output.hasPrefix("/") || output.hasPrefix("~") {
        path = URL(fileURLWithPath: (output as NSString).expandingTildeInPath)
    } else {
        path = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
            .appendingPathComponent(output)
    }
    try FileManager.default.createDirectory(at: path, withIntermediateDirectories: true)
    return path
}

public func exportEmail(
    record: EmailRecord, outputDir: URL, index: Int, mailDir: URL
) -> URL? {
    let mailboxPath = mailboxURLToPath(record.mailboxURL, mailDir: mailDir)
    let emlxPath = mailboxPath.flatMap { findEMLX(msgID: record.msgID, mailboxPath: $0) }

    let parsed = emlxPath.map { extractEmailContent(emlxPath: $0) }
    let emlxFilename = emlxPath?.lastPathComponent

    let dateStr = String(normalizeTimestamp(record.dateSentRaw).prefix(10))
    let subject = record.subject ?? "no-subject"
    let safeSubject = sanitizeFilename(subject)
    let filename = String(format: "%03d_%@_%@.md", index, dateStr, safeSubject)
    let outPath = outputDir.appendingPathComponent(filename)

    let markdown = formatEmailMarkdown(record: record, parsed: parsed, emlxFilename: emlxFilename)

    do {
        try markdown.write(to: outPath, atomically: true, encoding: .utf8)
        return outPath
    } catch {
        return nil
    }
}

public func runExport(
    keywords: [String], output: String = "output", limit: Int = 0,
    mailDir: URL? = nil, mailBase: URL? = nil
) throws -> [URL] {
    let config = try resolveMailConfig(mailDir: mailDir, mailBase: mailBase)
    let outputDir = try resolveOutputDir(output)

    let db = try MailDatabase(path: config.envelopeDB.path)
    let results = try db.searchEmails(keywords: keywords, limit: limit)

    if results.isEmpty { return [] }

    var exported: [URL] = []
    for (i, record) in results.enumerated() {
        if let path = exportEmail(record: record, outputDir: outputDir, index: i + 1, mailDir: config.mailDir) {
            exported.append(path)
        }
    }
    return exported
}

public func listMatches(
    keywords: [String], limit: Int = 0,
    mailDir: URL? = nil, mailBase: URL? = nil
) throws -> [EmailRecord] {
    let config = try resolveMailConfig(mailDir: mailDir, mailBase: mailBase)
    let db = try MailDatabase(path: config.envelopeDB.path)
    return try db.searchEmails(keywords: keywords, limit: limit)
}

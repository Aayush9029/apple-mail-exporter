import Foundation

public let macEpochOffsetSeconds: Double = 978_307_200

public func sanitizeFilename(_ value: String, maxLen: Int = 80) -> String {
    // [<>:"/\|?*] + control chars → underscore
    let pattern = #"[<>:"/\\|?*\x00-\x1f]"#
    var safe = value.replacingOccurrences(of: pattern, with: "_", options: .regularExpression)
    safe = safe.replacingOccurrences(of: #"\s+"#, with: "_", options: .regularExpression)
    safe = safe.replacingOccurrences(of: #"_+"#, with: "_", options: .regularExpression)
    safe = safe.trimmingCharacters(in: CharacterSet(charactersIn: "_ "))
    if safe.isEmpty { return "untitled" }
    return safe.count > maxLen ? String(safe.prefix(maxLen)) : safe
}

public func normalizeTimestamp(_ raw: Double?) -> String {
    guard let raw, raw != 0 else { return "unknown" }

    var ts = raw
    if ts > 1_000_000_000_000 { ts /= 1000.0 }
    if ts < 1_000_000_000 { ts += macEpochOffsetSeconds }

    let date = Date(timeIntervalSince1970: ts)
    let fmt = DateFormatter()
    fmt.dateFormat = "yyyy-MM-dd HH:mm:ss"
    fmt.timeZone = TimeZone(identifier: "UTC")
    return fmt.string(from: date)
}

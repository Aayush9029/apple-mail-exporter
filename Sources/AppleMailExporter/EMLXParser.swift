import Foundation

public func extractEmailContent(emlxPath: URL) -> ParsedEmail {
    guard let raw = try? Data(contentsOf: emlxPath) else {
        return ParsedEmail(headers: [:], body: "")
    }

    guard let firstNL = raw.firstIndex(of: UInt8(ascii: "\n")) else {
        return ParsedEmail(headers: [:], body: String(data: raw, encoding: .utf8) ?? "")
    }

    let byteCountStr = String(data: raw[raw.startIndex..<firstNL], encoding: .utf8)?.trimmingCharacters(in: .whitespaces) ?? ""
    let byteCount = Int(byteCountStr) ?? (raw.count - firstNL.advanced(by: 0) - 1)

    let emailStart = raw.index(after: firstNL)
    let emailEnd = min(raw.index(emailStart, offsetBy: byteCount, limitedBy: raw.endIndex) ?? raw.endIndex, raw.endIndex)
    let emailText = String(data: raw[emailStart..<emailEnd], encoding: .utf8)
        ?? String(data: raw[emailStart..<emailEnd], encoding: .ascii) ?? ""

    // Split headers and body at blank line
    var headerEnd = emailText.range(of: "\n\n")
    if headerEnd == nil {
        headerEnd = emailText.range(of: "\r\n\r\n")
    }

    let headersRaw: String
    let bodyRaw: String
    if let headerEnd {
        headersRaw = String(emailText[emailText.startIndex..<headerEnd.lowerBound])
        bodyRaw = String(emailText[headerEnd.upperBound...])
    } else {
        headersRaw = ""
        bodyRaw = emailText
    }

    let headers = extractHeaders(headersRaw)

    let cte = (headers["Content-Transfer-Encoding"] ?? "").lowercased()
    let body: String
    if cte.contains("quoted-printable") {
        body = decodeQuotedPrintable(bodyRaw)
    } else if cte.contains("base64") {
        body = decodeBase64(bodyRaw)
    } else {
        body = bodyRaw
    }

    return ParsedEmail(headers: headers, body: body)
}

private let headerNames = ["From", "To", "Subject", "Date", "Content-Type", "Content-Transfer-Encoding"]

private func extractHeaders(_ raw: String) -> [String: String] {
    var result: [String: String] = [:]

    for hdr in headerNames {
        // ^HeaderName:\s*(.+?)(?=\n[^\s]|\n\n|\Z) with MULTILINE | DOTALL
        let pattern = "^\(hdr):\\s*(.+?)(?=\\n[^\\s]|\\n\\n|\\Z)"
        guard let regex = try? NSRegularExpression(pattern: pattern, options: [.anchorsMatchLines, .dotMatchesLineSeparators]),
              let match = regex.firstMatch(in: raw, range: NSRange(raw.startIndex..., in: raw)),
              let valueRange = Range(match.range(at: 1), in: raw)
        else { continue }

        // Unfold continuation lines
        var val = String(raw[valueRange]).trimmingCharacters(in: .whitespacesAndNewlines)
        val = val.replacingOccurrences(of: #"\r?\n\s+"#, with: " ", options: .regularExpression)
        result[hdr] = val
    }

    return result
}

private func decodeQuotedPrintable(_ input: String) -> String {
    var result = ""
    var i = input.startIndex
    while i < input.endIndex {
        let ch = input[i]
        if ch == "=" {
            let next1 = input.index(after: i)
            if next1 < input.endIndex {
                // Soft line break: =\r\n or =\n
                if input[next1] == "\r" {
                    let next2 = input.index(after: next1)
                    if next2 < input.endIndex && input[next2] == "\n" {
                        i = input.index(after: next2)
                    } else {
                        i = next2
                    }
                    continue
                }
                if input[next1] == "\n" {
                    i = input.index(after: next1)
                    continue
                }
                // Hex pair
                let next2 = input.index(after: next1)
                if next2 < input.endIndex {
                    let hex = String(input[next1...next2])
                    if let byte = UInt8(hex, radix: 16) {
                        result.append(Character(UnicodeScalar(byte)))
                        i = input.index(after: next2)
                        continue
                    }
                }
            }
            result.append(ch)
            i = input.index(after: i)
        } else {
            result.append(ch)
            i = input.index(after: i)
        }
    }
    return result
}

private func decodeBase64(_ input: String) -> String {
    let cleaned = input.replacingOccurrences(of: #"\s+"#, with: "", options: .regularExpression)
    guard let data = Data(base64Encoded: cleaned) else { return input }
    return String(data: data, encoding: .utf8) ?? input
}

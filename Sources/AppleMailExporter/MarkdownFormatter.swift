import Foundation

public func formatEmailMarkdown(record: EmailRecord, parsed: ParsedEmail?, emlxFilename: String?) -> String {
    let subject = record.subject ?? "no-subject"
    let sender = record.senderName ?? record.senderAddress ?? "unknown"
    let dateStr = normalizeTimestamp(record.dateSentRaw)
    let dateShort = String(dateStr.prefix(10))

    var md = "# \(subject)\n\n"
    md += "| Field | Value |\n|---|---|\n"
    md += "| **From** | \(sender) <\(record.senderAddress ?? "")> |\n"
    md += "| **Date** | \(dateShort) |\n"
    md += "| **Subject** | \(subject) |\n"
    md += "| **Message ID** | \(record.msgID) |\n"
    md += "| **Mailbox** | \(record.mailboxURL ?? "") |\n"
    if let emlxFilename {
        md += "| **Source** | `\(emlxFilename)` |\n"
    }
    md += "\n---\n\n"

    if let parsed {
        if !parsed.headers.isEmpty {
            md += "## Headers\n\n```\n"
            for (key, value) in parsed.headers {
                md += "\(key): \(value)\n"
            }
            md += "```\n\n"
        }

        md += "## Body\n\n"
        let bodyLower = parsed.body.lowercased()
        if bodyLower.contains("<html") || bodyLower.contains("<!doctype") {
            md += "```html\n\(parsed.body)\n```\n"
        } else {
            md += "\(parsed.body)\n"
        }
    } else {
        md += "## Body\n\n(Email body not available locally — only metadata from index)\n"
    }

    return md
}

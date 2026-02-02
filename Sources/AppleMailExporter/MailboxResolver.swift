import Foundation

// imap://UUID/INBOX → {mailDir}/UUID/INBOX.mbox
// imap://UUID/[Gmail]/All%20Mail → {mailDir}/UUID/[Gmail].mbox/All Mail.mbox
public func mailboxURLToPath(_ urlString: String?, mailDir: URL) -> URL? {
    guard let urlString, !urlString.isEmpty else { return nil }

    let pattern = #"(?:imap|local)://([^/]+)/(.+)"#
    guard let regex = try? NSRegularExpression(pattern: pattern),
          let match = regex.firstMatch(in: urlString, range: NSRange(urlString.startIndex..., in: urlString)),
          let accountRange = Range(match.range(at: 1), in: urlString),
          let pathRange = Range(match.range(at: 2), in: urlString)
    else { return nil }

    let accountUUID = String(urlString[accountRange])
    let pathPart = String(urlString[pathRange]).removingPercentEncoding ?? String(urlString[pathRange])

    var result = mailDir.appendingPathComponent(accountUUID)
    for segment in pathPart.split(separator: "/") {
        result = result.appendingPathComponent("\(segment).mbox")
    }
    return result
}

public func findEMLX(msgID: Int, mailboxPath: URL?) -> URL? {
    guard let mailboxPath else { return nil }
    let fm = FileManager.default
    guard fm.fileExists(atPath: mailboxPath.path) else { return nil }

    let fname = "\(msgID).emlx"
    let partialFname = "\(msgID).partial.emlx"

    guard let enumerator = fm.enumerator(at: mailboxPath, includingPropertiesForKeys: nil) else {
        return nil
    }

    var partialMatch: URL?
    for case let fileURL as URL in enumerator {
        let name = fileURL.lastPathComponent
        if name == fname { return fileURL }
        if name == partialFname { partialMatch = fileURL }
    }
    return partialMatch
}

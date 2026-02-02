import Foundation
import CSQLite

public final class MailDatabase {
    private var db: OpaquePointer?

    public init(path: String) throws {
        let rc = sqlite3_open_v2(path, &db, SQLITE_OPEN_READONLY, nil)

        if rc == SQLITE_CANTOPEN {
            throw MailError.noFullDiskAccess
        }
        guard rc == SQLITE_OK else {
            let msg = db.flatMap { String(cString: sqlite3_errmsg($0)) } ?? "unknown"
            sqlite3_close(db)
            db = nil
            throw MailError.databaseOpenFailed(msg)
        }

        sqlite3_busy_timeout(db, 5000)
    }

    deinit {
        if let db { sqlite3_close(db) }
    }

    public func searchEmails(keywords: [String], limit: Int = 0) throws -> [EmailRecord] {
        let filtered = keywords.filter { !$0.isEmpty }
        guard !filtered.isEmpty else { return [] }

        var whereClauses: [String] = []
        var params: [String] = []
        for kw in filtered {
            let pattern = "%\(kw)%"
            whereClauses.append("(s.subject LIKE ? OR a.address LIKE ? OR a.comment LIKE ?)")
            params.append(contentsOf: [pattern, pattern, pattern])
        }

        let whereSQL = whereClauses.joined(separator: " OR ")
        let limitSQL = limit > 0 ? "LIMIT \(limit)" : ""

        let query = """
            SELECT
                m.ROWID as msg_id,
                s.subject,
                a.address as sender_address,
                a.comment as sender_name,
                m.date_sent as date_sent_raw,
                mb.url as mailbox_url
            FROM messages m
            JOIN subjects s ON m.subject = s.ROWID
            LEFT JOIN addresses a ON m.sender = a.ROWID
            LEFT JOIN mailboxes mb ON m.mailbox = mb.ROWID
            WHERE \(whereSQL)
            ORDER BY m.date_sent DESC
            \(limitSQL)
            """

        var stmt: OpaquePointer?
        let prepareRC = sqlite3_prepare_v2(db, query, -1, &stmt, nil)

        if prepareRC == SQLITE_BUSY {
            throw MailError.databaseBusy
        }
        guard prepareRC == SQLITE_OK else {
            let msg = db.flatMap { String(cString: sqlite3_errmsg($0)) } ?? "unknown"
            throw MailError.databaseError(msg)
        }
        defer { sqlite3_finalize(stmt) }

        for (i, param) in params.enumerated() {
            sqlite3_bind_text(stmt, Int32(i + 1), (param as NSString).utf8String, -1, nil)
        }

        var results: [EmailRecord] = []
        while sqlite3_step(stmt) == SQLITE_ROW {
            let msgID = Int(sqlite3_column_int64(stmt, 0))
            let subject = columnText(stmt, 1)
            let senderAddress = columnText(stmt, 2)
            let senderName = columnText(stmt, 3)
            let dateSentRaw = sqlite3_column_type(stmt, 4) != SQLITE_NULL
                ? Double(sqlite3_column_double(stmt, 4)) : nil
            let mailboxURL = columnText(stmt, 5)

            results.append(EmailRecord(
                msgID: msgID, subject: subject, senderAddress: senderAddress,
                senderName: senderName, dateSentRaw: dateSentRaw, mailboxURL: mailboxURL
            ))
        }

        return results
    }

    private func columnText(_ stmt: OpaquePointer?, _ col: Int32) -> String? {
        guard let cStr = sqlite3_column_text(stmt, col) else { return nil }
        return String(cString: cStr)
    }
}

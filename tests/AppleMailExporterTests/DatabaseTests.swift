import Testing
import Foundation
import CSQLite
@testable import AppleMailExporter

@Suite struct DatabaseTests {

    private func createTestDB() throws -> String {
        let tmp = FileManager.default.temporaryDirectory
            .appendingPathComponent("\(UUID().uuidString).sqlite")
        let path = tmp.path

        var db: OpaquePointer?
        guard sqlite3_open(path, &db) == SQLITE_OK else {
            Issue.record("Failed to create test DB")
            return path
        }
        defer { sqlite3_close(db) }

        let schema = """
            CREATE TABLE subjects (ROWID INTEGER PRIMARY KEY, subject TEXT);
            CREATE TABLE addresses (ROWID INTEGER PRIMARY KEY, address TEXT, comment TEXT);
            CREATE TABLE mailboxes (ROWID INTEGER PRIMARY KEY, url TEXT);
            CREATE TABLE messages (
                ROWID INTEGER PRIMARY KEY, subject INTEGER, sender INTEGER,
                date_sent REAL, mailbox INTEGER
            );
            INSERT INTO subjects VALUES (1, 'Airbnb Receipt');
            INSERT INTO subjects VALUES (2, 'Flight Booking');
            INSERT INTO addresses VALUES (1, 'noreply@airbnb.com', 'Airbnb');
            INSERT INTO addresses VALUES (2, 'booking@airline.com', 'Air Canada');
            INSERT INTO mailboxes VALUES (1, 'imap://UUID123/INBOX');
            INSERT INTO messages VALUES (100, 1, 1, 1700000000, 1);
            INSERT INTO messages VALUES (101, 2, 2, 1700001000, 1);
            """

        var errMsg: UnsafeMutablePointer<CChar>?
        sqlite3_exec(db, schema, nil, nil, &errMsg)
        if let errMsg {
            Issue.record("Schema error: \(String(cString: errMsg))")
            sqlite3_free(errMsg)
        }

        return path
    }

    @Test func searchBySubject() throws {
        let path = try createTestDB()
        defer { try? FileManager.default.removeItem(atPath: path) }

        let mailDB = try MailDatabase(path: path)
        let results = try mailDB.searchEmails(keywords: ["airbnb"])
        #expect(results.count == 1)
        #expect(results[0].subject == "Airbnb Receipt")
        #expect(results[0].senderAddress == "noreply@airbnb.com")
    }

    @Test func searchBySender() throws {
        let path = try createTestDB()
        defer { try? FileManager.default.removeItem(atPath: path) }

        let mailDB = try MailDatabase(path: path)
        let results = try mailDB.searchEmails(keywords: ["airline.com"])
        #expect(results.count == 1)
        #expect(results[0].subject == "Flight Booking")
    }

    @Test func searchMultipleKeywords() throws {
        let path = try createTestDB()
        defer { try? FileManager.default.removeItem(atPath: path) }

        let mailDB = try MailDatabase(path: path)
        let results = try mailDB.searchEmails(keywords: ["airbnb", "flight"])
        #expect(results.count == 2)
    }

    @Test func searchWithLimit() throws {
        let path = try createTestDB()
        defer { try? FileManager.default.removeItem(atPath: path) }

        let mailDB = try MailDatabase(path: path)
        let results = try mailDB.searchEmails(keywords: ["airbnb", "flight"], limit: 1)
        #expect(results.count == 1)
    }

    @Test func searchEmptyKeywords() throws {
        let path = try createTestDB()
        defer { try? FileManager.default.removeItem(atPath: path) }

        let mailDB = try MailDatabase(path: path)
        let results = try mailDB.searchEmails(keywords: [])
        #expect(results.isEmpty)
    }

    @Test func searchNoMatch() throws {
        let path = try createTestDB()
        defer { try? FileManager.default.removeItem(atPath: path) }

        let mailDB = try MailDatabase(path: path)
        let results = try mailDB.searchEmails(keywords: ["nonexistent"])
        #expect(results.isEmpty)
    }

    @Test func resultsOrderedByDateDescending() throws {
        let path = try createTestDB()
        defer { try? FileManager.default.removeItem(atPath: path) }

        let mailDB = try MailDatabase(path: path)
        let results = try mailDB.searchEmails(keywords: ["airbnb", "flight"])
        #expect(results.count == 2)
        #expect(results[0].subject == "Flight Booking")
        #expect(results[1].subject == "Airbnb Receipt")
    }
}

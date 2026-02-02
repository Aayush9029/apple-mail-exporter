import XCTest
import CSQLite
@testable import AppleMailExporter

final class DatabaseTests: XCTestCase {

    private func createTestDB() throws -> String {
        let tmp = FileManager.default.temporaryDirectory
            .appendingPathComponent("\(UUID().uuidString).sqlite")
        let path = tmp.path

        var db: OpaquePointer?
        guard sqlite3_open(path, &db) == SQLITE_OK else {
            XCTFail("Failed to create test DB")
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
            XCTFail("Schema error: \(String(cString: errMsg))")
            sqlite3_free(errMsg)
        }

        return path
    }

    func testSearchBySubject() throws {
        let path = try createTestDB()
        defer { try? FileManager.default.removeItem(atPath: path) }

        let mailDB = try MailDatabase(path: path)
        let results = try mailDB.searchEmails(keywords: ["airbnb"])
        XCTAssertEqual(results.count, 1)
        XCTAssertEqual(results[0].subject, "Airbnb Receipt")
        XCTAssertEqual(results[0].senderAddress, "noreply@airbnb.com")
    }

    func testSearchBySender() throws {
        let path = try createTestDB()
        defer { try? FileManager.default.removeItem(atPath: path) }

        let mailDB = try MailDatabase(path: path)
        let results = try mailDB.searchEmails(keywords: ["airline.com"])
        XCTAssertEqual(results.count, 1)
        XCTAssertEqual(results[0].subject, "Flight Booking")
    }

    func testSearchMultipleKeywords() throws {
        let path = try createTestDB()
        defer { try? FileManager.default.removeItem(atPath: path) }

        let mailDB = try MailDatabase(path: path)
        let results = try mailDB.searchEmails(keywords: ["airbnb", "flight"])
        XCTAssertEqual(results.count, 2)
    }

    func testSearchWithLimit() throws {
        let path = try createTestDB()
        defer { try? FileManager.default.removeItem(atPath: path) }

        let mailDB = try MailDatabase(path: path)
        let results = try mailDB.searchEmails(keywords: ["airbnb", "flight"], limit: 1)
        XCTAssertEqual(results.count, 1)
    }

    func testSearchEmptyKeywords() throws {
        let path = try createTestDB()
        defer { try? FileManager.default.removeItem(atPath: path) }

        let mailDB = try MailDatabase(path: path)
        let results = try mailDB.searchEmails(keywords: [])
        XCTAssertTrue(results.isEmpty)
    }

    func testSearchNoMatch() throws {
        let path = try createTestDB()
        defer { try? FileManager.default.removeItem(atPath: path) }

        let mailDB = try MailDatabase(path: path)
        let results = try mailDB.searchEmails(keywords: ["nonexistent"])
        XCTAssertTrue(results.isEmpty)
    }

    func testResultsOrderedByDateDescending() throws {
        let path = try createTestDB()
        defer { try? FileManager.default.removeItem(atPath: path) }

        let mailDB = try MailDatabase(path: path)
        let results = try mailDB.searchEmails(keywords: ["airbnb", "flight"])
        XCTAssertEqual(results.count, 2)
        XCTAssertEqual(results[0].subject, "Flight Booking")
        XCTAssertEqual(results[1].subject, "Airbnb Receipt")
    }
}

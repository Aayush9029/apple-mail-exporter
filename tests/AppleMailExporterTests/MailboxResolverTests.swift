import XCTest
@testable import AppleMailExporter

final class MailboxResolverTests: XCTestCase {

    func testImapURLToPath() {
        let mailDir = URL(fileURLWithPath: "/Mail")
        let result = mailboxURLToPath("imap://UUID/INBOX", mailDir: mailDir)
        XCTAssertEqual(result?.path, "/Mail/UUID/INBOX.mbox")
    }

    func testNestedURLWithEncoding() {
        let mailDir = URL(fileURLWithPath: "/Mail")
        let result = mailboxURLToPath("imap://UUID/[Gmail]/All%20Mail", mailDir: mailDir)
        XCTAssertEqual(result?.path, "/Mail/UUID/[Gmail].mbox/All Mail.mbox")
    }

    func testLocalURL() {
        let mailDir = URL(fileURLWithPath: "/Mail")
        let result = mailboxURLToPath("local://UUID/Drafts", mailDir: mailDir)
        XCTAssertEqual(result?.path, "/Mail/UUID/Drafts.mbox")
    }

    func testNilURL() {
        let mailDir = URL(fileURLWithPath: "/Mail")
        XCTAssertNil(mailboxURLToPath(nil, mailDir: mailDir))
    }

    func testInvalidURL() {
        let mailDir = URL(fileURLWithPath: "/Mail")
        XCTAssertNil(mailboxURLToPath("garbage", mailDir: mailDir))
    }

    func testFindEMLX() throws {
        let tmp = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        let subdir = tmp.appendingPathComponent("Messages")
        try FileManager.default.createDirectory(at: subdir, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: tmp) }

        let emlxFile = subdir.appendingPathComponent("123.emlx")
        try Data("test".utf8).write(to: emlxFile)

        let found = findEMLX(msgID: 123, mailboxPath: tmp)
        XCTAssertNotNil(found)
        XCTAssertEqual(found?.lastPathComponent, "123.emlx")
    }

    func testFindPartialEMLX() throws {
        let tmp = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        let subdir = tmp.appendingPathComponent("Messages")
        try FileManager.default.createDirectory(at: subdir, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: tmp) }

        let partialFile = subdir.appendingPathComponent("456.partial.emlx")
        try Data("test".utf8).write(to: partialFile)

        let found = findEMLX(msgID: 456, mailboxPath: tmp)
        XCTAssertNotNil(found)
        XCTAssertEqual(found?.lastPathComponent, "456.partial.emlx")
    }

    func testFindEMLXMissingDir() {
        let missing = URL(fileURLWithPath: "/nonexistent-\(UUID().uuidString)")
        XCTAssertNil(findEMLX(msgID: 1, mailboxPath: missing))
    }

    func testFindEMLXNilPath() {
        XCTAssertNil(findEMLX(msgID: 1, mailboxPath: nil))
    }
}

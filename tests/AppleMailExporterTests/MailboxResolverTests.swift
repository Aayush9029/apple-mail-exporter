import Testing
import Foundation
@testable import AppleMailExporter

@Suite struct MailboxResolverTests {

    @Test(arguments: [
        ("imap://UUID/INBOX", "/Mail/UUID/INBOX.mbox"),
        ("imap://UUID/[Gmail]/All%20Mail", "/Mail/UUID/[Gmail].mbox/All Mail.mbox"),
        ("local://UUID/Drafts", "/Mail/UUID/Drafts.mbox"),
    ])
    func mailboxURLToPathResolution(urlString: String, expectedPath: String) {
        let mailDir = URL(fileURLWithPath: "/Mail")
        let result = mailboxURLToPath(urlString, mailDir: mailDir)
        #expect(result?.path == expectedPath)
    }

    @Test(arguments: [nil, "garbage"] as [String?])
    func mailboxURLToPathReturnsNil(urlString: String?) {
        let mailDir = URL(fileURLWithPath: "/Mail")
        #expect(mailboxURLToPath(urlString, mailDir: mailDir) == nil)
    }

    @Test func findEMLXFile() throws {
        let tmp = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        let subdir = tmp.appendingPathComponent("Messages")
        try FileManager.default.createDirectory(at: subdir, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: tmp) }

        let emlxFile = subdir.appendingPathComponent("123.emlx")
        try Data("test".utf8).write(to: emlxFile)

        let found = findEMLX(msgID: 123, mailboxPath: tmp)
        #expect(found != nil)
        #expect(found?.lastPathComponent == "123.emlx")
    }

    @Test func findPartialEMLX() throws {
        let tmp = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        let subdir = tmp.appendingPathComponent("Messages")
        try FileManager.default.createDirectory(at: subdir, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: tmp) }

        let partialFile = subdir.appendingPathComponent("456.partial.emlx")
        try Data("test".utf8).write(to: partialFile)

        let found = findEMLX(msgID: 456, mailboxPath: tmp)
        #expect(found != nil)
        #expect(found?.lastPathComponent == "456.partial.emlx")
    }

    @Test func findEMLXMissingDir() {
        let missing = URL(fileURLWithPath: "/nonexistent-\(UUID().uuidString)")
        #expect(findEMLX(msgID: 1, mailboxPath: missing) == nil)
    }

    @Test func findEMLXNilPath() {
        #expect(findEMLX(msgID: 1, mailboxPath: nil) == nil)
    }
}

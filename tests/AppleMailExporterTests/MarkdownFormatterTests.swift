import XCTest
@testable import AppleMailExporter

final class MarkdownFormatterTests: XCTestCase {

    func testBasicFormatting() {
        let record = EmailRecord(
            msgID: 42, subject: "Test Subject",
            senderAddress: "test@example.com", senderName: "Test User",
            dateSentRaw: 1700000000, mailboxURL: "imap://UUID/INBOX"
        )
        let parsed = ParsedEmail(
            headers: ["Subject": "Test Subject", "From": "Test User <test@example.com>"],
            body: "Hello there"
        )
        let md = formatEmailMarkdown(record: record, parsed: parsed, emlxFilename: "42.emlx")

        XCTAssertTrue(md.contains("# Test Subject"))
        XCTAssertTrue(md.contains("| **From** |"))
        XCTAssertTrue(md.contains("test@example.com"))
        XCTAssertTrue(md.contains("## Headers"))
        XCTAssertTrue(md.contains("## Body"))
        XCTAssertTrue(md.contains("Hello there"))
        XCTAssertTrue(md.contains("`42.emlx`"))
    }

    func testHTMLBodyWrappedInCodeBlock() {
        let record = EmailRecord(msgID: 1, subject: "HTML")
        let parsed = ParsedEmail(headers: [:], body: "<html><body>Hi</body></html>")
        let md = formatEmailMarkdown(record: record, parsed: parsed, emlxFilename: nil)

        XCTAssertTrue(md.contains("```html"))
    }

    func testMissingEmailBody() {
        let record = EmailRecord(msgID: 1, subject: "No Body")
        let md = formatEmailMarkdown(record: record, parsed: nil, emlxFilename: nil)

        XCTAssertTrue(md.contains("not available locally"))
    }

    func testNilFieldsHandled() {
        let record = EmailRecord(msgID: 1)
        let md = formatEmailMarkdown(record: record, parsed: nil, emlxFilename: nil)

        XCTAssertTrue(md.contains("# no-subject"))
        XCTAssertTrue(md.contains("unknown"))
    }
}

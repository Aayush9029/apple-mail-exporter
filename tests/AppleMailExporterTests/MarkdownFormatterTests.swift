import Testing
@testable import AppleMailExporter

@Suite struct MarkdownFormatterTests {

    @Test func basicFormatting() {
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

        #expect(md.contains("# Test Subject"))
        #expect(md.contains("| **From** |"))
        #expect(md.contains("test@example.com"))
        #expect(md.contains("## Headers"))
        #expect(md.contains("## Body"))
        #expect(md.contains("Hello there"))
        #expect(md.contains("`42.emlx`"))
    }

    @Test func htmlBodyWrappedInCodeBlock() {
        let record = EmailRecord(msgID: 1, subject: "HTML")
        let parsed = ParsedEmail(headers: [:], body: "<html><body>Hi</body></html>")
        let md = formatEmailMarkdown(record: record, parsed: parsed, emlxFilename: nil)

        #expect(md.contains("```html"))
    }

    @Test func missingEmailBody() {
        let record = EmailRecord(msgID: 1, subject: "No Body")
        let md = formatEmailMarkdown(record: record, parsed: nil, emlxFilename: nil)

        #expect(md.contains("not available locally"))
    }

    @Test func nilFieldsHandled() {
        let record = EmailRecord(msgID: 1)
        let md = formatEmailMarkdown(record: record, parsed: nil, emlxFilename: nil)

        #expect(md.contains("# no-subject"))
        #expect(md.contains("unknown"))
    }
}

import XCTest
@testable import AppleMailExporter

final class EMLXParserTests: XCTestCase {

    private func writeEMLX(at path: URL, emailBytes: Data) throws {
        let payload = "\(emailBytes.count)\n".data(using: .utf8)! + emailBytes + "\n".data(using: .utf8)!
        try payload.write(to: path)
    }

    func testBasicParsing() throws {
        let tmp = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try FileManager.default.createDirectory(at: tmp, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: tmp) }

        let emlx = tmp.appendingPathComponent("1.emlx")
        let email = "From: Test <test@example.com>\nSubject: Hello\n\nBody text here".data(using: .utf8)!
        try writeEMLX(at: emlx, emailBytes: email)

        let result = extractEmailContent(emlxPath: emlx)
        XCTAssertEqual(result.headers["Subject"], "Hello")
        XCTAssertEqual(result.headers["From"], "Test <test@example.com>")
        XCTAssertTrue(result.body.contains("Body text here"))
    }

    func testQuotedPrintableDecoding() throws {
        let tmp = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try FileManager.default.createDirectory(at: tmp, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: tmp) }

        let emlx = tmp.appendingPathComponent("2.emlx")
        let email = "Subject: QP Test\nContent-Transfer-Encoding: quoted-printable\n\nHello=0AWorld".data(using: .utf8)!
        try writeEMLX(at: emlx, emailBytes: email)

        let result = extractEmailContent(emlxPath: emlx)
        XCTAssertTrue(result.body.contains("Hello"))
        XCTAssertTrue(result.body.contains("World"))
        XCTAssertTrue(result.body.contains("\n"))
    }

    func testBase64Decoding() throws {
        let tmp = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try FileManager.default.createDirectory(at: tmp, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: tmp) }

        let emlx = tmp.appendingPathComponent("3.emlx")
        let base64Body = Data("Hello World".utf8).base64EncodedString()
        let email = "Subject: B64 Test\nContent-Transfer-Encoding: base64\n\n\(base64Body)".data(using: .utf8)!
        try writeEMLX(at: emlx, emailBytes: email)

        let result = extractEmailContent(emlxPath: emlx)
        XCTAssertTrue(result.body.contains("Hello World"))
    }

    func testFoldedHeaders() throws {
        let tmp = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try FileManager.default.createDirectory(at: tmp, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: tmp) }

        let emlx = tmp.appendingPathComponent("4.emlx")
        let email = "Subject: This is a very\n long subject line\nFrom: test@example.com\n\nBody".data(using: .utf8)!
        try writeEMLX(at: emlx, emailBytes: email)

        let result = extractEmailContent(emlxPath: emlx)
        XCTAssertEqual(result.headers["Subject"], "This is a very long subject line")
    }

    func testMissingFile() {
        let missing = URL(fileURLWithPath: "/nonexistent-\(UUID().uuidString).emlx")
        let result = extractEmailContent(emlxPath: missing)
        XCTAssertTrue(result.headers.isEmpty)
        XCTAssertEqual(result.body, "")
    }

    func testQuotedPrintableSoftLineBreak() throws {
        let tmp = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try FileManager.default.createDirectory(at: tmp, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: tmp) }

        let emlx = tmp.appendingPathComponent("5.emlx")
        let email = "Subject: Soft\nContent-Transfer-Encoding: quoted-printable\n\nLine1=\nLine2".data(using: .utf8)!
        try writeEMLX(at: emlx, emailBytes: email)

        let result = extractEmailContent(emlxPath: emlx)
        XCTAssertTrue(result.body.contains("Line1Line2"))
    }
}

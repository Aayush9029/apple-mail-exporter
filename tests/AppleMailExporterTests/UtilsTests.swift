import XCTest
@testable import AppleMailExporter

final class UtilsTests: XCTestCase {

    func testSanitizeFilenameRemovesInvalidChars() {
        XCTAssertEqual(sanitizeFilename("Hello: World?"), "Hello_World")
    }

    func testSanitizeFilenameWhitespaceOnly() {
        XCTAssertEqual(sanitizeFilename("   "), "untitled")
    }

    func testSanitizeFilenameEmptyString() {
        XCTAssertEqual(sanitizeFilename(""), "untitled")
    }

    func testSanitizeFilenameTruncation() {
        let long = String(repeating: "a", count: 120)
        let result = sanitizeFilename(long)
        XCTAssertEqual(result.count, 80)
    }

    func testSanitizeFilenameCollapsesUnderscores() {
        XCTAssertEqual(sanitizeFilename("a:::b"), "a_b")
    }

    func testNormalizeTimestampUnixEpoch() {
        let result = normalizeTimestamp(1_700_000_000)
        XCTAssertTrue(result.hasPrefix("2023"), "Expected 2023, got \(result)")
    }

    func testNormalizeTimestampMacEpoch() {
        let result = normalizeTimestamp(100_000_000)
        XCTAssertTrue(result.hasPrefix("200"), "Expected 200x, got \(result)")
    }

    func testNormalizeTimestampNil() {
        XCTAssertEqual(normalizeTimestamp(nil), "unknown")
    }

    func testNormalizeTimestampZero() {
        XCTAssertEqual(normalizeTimestamp(0), "unknown")
    }

    func testNormalizeTimestampMilliseconds() {
        let result = normalizeTimestamp(1_700_000_000_000)
        XCTAssertTrue(result.hasPrefix("2023"), "Expected 2023, got \(result)")
    }

    func testMacEpochOffset() {
        XCTAssertEqual(macEpochOffsetSeconds, 978_307_200)
    }
}

import Testing
@testable import AppleMailExporter

@Suite struct UtilsTests {

    @Test(arguments: [
        ("Hello: World?", "Hello_World"),
        ("   ", "untitled"),
        ("", "untitled"),
        ("a:::b", "a_b"),
    ])
    func sanitizeFilenameExpected(input: String, expected: String) {
        #expect(sanitizeFilename(input) == expected)
    }

    @Test func sanitizeFilenameTruncation() {
        let long = String(repeating: "a", count: 120)
        let result = sanitizeFilename(long)
        #expect(result.count == 80)
    }

    @Test(arguments: [
        (1_700_000_000.0, "2023"),
        (100_000_000.0, "200"),
        (1_700_000_000_000.0, "2023"),
    ])
    func normalizeTimestampPrefix(value: Double, expectedPrefix: String) {
        let result = normalizeTimestamp(value)
        #expect(result.hasPrefix(expectedPrefix), "Expected \(expectedPrefix), got \(result)")
    }

    @Test(arguments: [nil, 0.0] as [Double?])
    func normalizeTimestampReturnsUnknown(value: Double?) {
        #expect(normalizeTimestamp(value) == "unknown")
    }

    @Test func macEpochOffset() {
        #expect(macEpochOffsetSeconds == 978_307_200)
    }
}

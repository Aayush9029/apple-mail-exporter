import XCTest
@testable import AppleMailExporter

final class ConfigTests: XCTestCase {

    func testFindMailVersionDirPicksHighest() throws {
        let tmp = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
        try FileManager.default.createDirectory(at: tmp, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: tmp) }

        for name in ["V8", "V10", "V11"] {
            try FileManager.default.createDirectory(
                at: tmp.appendingPathComponent(name),
                withIntermediateDirectories: false
            )
        }

        let result = try findMailVersionDir(base: tmp)
        XCTAssertEqual(result.lastPathComponent, "V11")
    }

    func testFindMailVersionDirThrowsWhenEmpty() throws {
        let tmp = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
        try FileManager.default.createDirectory(at: tmp, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: tmp) }

        XCTAssertThrowsError(try findMailVersionDir(base: tmp))
    }

    func testFindMailVersionDirThrowsWhenMissing() {
        let missing = URL(fileURLWithPath: "/nonexistent-\(UUID().uuidString)")
        XCTAssertThrowsError(try findMailVersionDir(base: missing))
    }

    func testMacEpochOffsetValue() {
        XCTAssertEqual(macEpochOffsetSeconds, 978_307_200)
    }
}

import Testing
import Foundation
@testable import AppleMailExporter

@Suite struct ConfigTests {

    @Test func findMailVersionDirPicksHighest() throws {
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
        #expect(result.lastPathComponent == "V11")
    }

    @Test func findMailVersionDirThrowsWhenEmpty() throws {
        let tmp = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
        try FileManager.default.createDirectory(at: tmp, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: tmp) }

        #expect(throws: (any Error).self) { try findMailVersionDir(base: tmp) }
    }

    @Test func findMailVersionDirThrowsWhenMissing() {
        let missing = URL(fileURLWithPath: "/nonexistent-\(UUID().uuidString)")
        #expect(throws: (any Error).self) { try findMailVersionDir(base: missing) }
    }

    @Test func macEpochOffsetValue() {
        #expect(macEpochOffsetSeconds == 978_307_200)
    }
}

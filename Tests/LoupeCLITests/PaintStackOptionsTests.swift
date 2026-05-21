import Foundation
import Testing
@testable import LoupeCLI

struct PaintStackOptionsTests {
    @Test func parsesPointAndRuntimeOptions() throws {
        let options = try PaintStackOptions([
            "--bundle-id", "com.example.App",
            "--point", "12,34",
            "--limit", "8",
            "--json",
        ])

        #expect(options.bundleID == "com.example.App")
        #expect(options.point?.x == 12)
        #expect(options.point?.y == 34)
        #expect(options.maxEntries == 8)
        #expect(options.json)
    }

    @Test func parsesSnapshotAndRef() throws {
        let options = try PaintStackOptions([
            "/tmp/snapshot.json",
            "--ref", "n12",
        ])

        #expect(options.snapshotURL?.path == "/tmp/snapshot.json")
        #expect(options.ref == "n12")
    }

    @Test func rejectsMissingTarget() {
        #expect(throws: Error.self) {
            _ = try PaintStackOptions([])
        }
    }
}

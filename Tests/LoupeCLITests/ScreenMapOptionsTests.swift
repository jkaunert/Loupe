@testable import LoupeCLI
import Testing

@Suite struct ScreenMapOptionsTests {
    @Test func parsesLiveRuntimeOptions() throws {
        let options = try ScreenMapOptions([
            "--bundle-id", "dev.loupe.example",
            "--include-hidden",
            "--include-containers",
            "--limit", "25",
            "--timeout", "2",
        ])

        #expect(options.snapshotURL == nil)
        #expect(options.bundleID == "dev.loupe.example")
        #expect(options.includeHidden)
        #expect(options.includeContainers)
        #expect(options.maxElements == 25)
        #expect(options.timeout == 2)
    }

    @Test func parsesSnapshotPath() throws {
        let options = try ScreenMapOptions(["/tmp/snapshot.json"])

        #expect(options.snapshotURL?.path == "/tmp/snapshot.json")
        #expect(options.maxElements == 200)
    }

    @Test func rejectsInvalidLimit() {
        #expect(throws: (any Error).self) {
            _ = try ScreenMapOptions(["--limit", "0"])
        }
    }
}

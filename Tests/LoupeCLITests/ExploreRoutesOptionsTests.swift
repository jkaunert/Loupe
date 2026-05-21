@testable import LoupeCLI
import LoupeCore
import Testing

@Suite struct ExploreRoutesOptionsTests {
    @Test func parsesDefaults() throws {
        let options = try ExploreRoutesOptions([])

        #expect(options.host.absoluteString == "http://127.0.0.1:8765")
        #expect(options.hostWasExplicit == false)
        #expect(options.limit == 5)
        #expect(options.backTestID == "BackButton")
        #expect(options.backPoint == LoupePoint(x: 36, y: 84))
    }

    @Test func parsesRuntimeAndOutputOptions() throws {
        let options = try ExploreRoutesOptions([
            "--host", "http://127.0.0.1:9736",
            "--udid", "SIM-1",
            "--bundle-id", "com.example.App",
            "--limit", "3",
            "--timeout", "2",
            "--settle", "0.1",
            "--output", "/tmp/routes.json",
            "--trace-dir", "/tmp/routes",
            "--back-point", "20,44",
            "--no-back-test-id",
            "--json",
        ])

        #expect(options.host.absoluteString == "http://127.0.0.1:9736")
        #expect(options.hostWasExplicit)
        #expect(options.udid == "SIM-1")
        #expect(options.bundleID == "com.example.App")
        #expect(options.limit == 3)
        #expect(options.timeout == 2)
        #expect(options.settleDelay == 0.1)
        #expect(options.outputURL?.path == "/tmp/routes.json")
        #expect(options.traceDirectory?.path == "/tmp/routes")
        #expect(options.backPoint == LoupePoint(x: 20, y: 44))
        #expect(options.backTestID == nil)
        #expect(options.json)
    }

    @Test func rejectsInvalidLimit() {
        #expect(throws: (any Error).self) {
            _ = try ExploreRoutesOptions(["--limit", "0"])
        }
    }
}

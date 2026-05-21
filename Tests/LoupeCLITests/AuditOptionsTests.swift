@testable import LoupeCLI
import LoupeCore
import Testing

@Suite struct AuditOptionsTests {
    @Test func parsesKindFilters() throws {
        let options = try AuditOptions([
            "/tmp/snapshot.json",
            "--kind", "lowTextContrast,overlappingSiblings",
            "--exclude-kind", "childOutsideParent",
        ])

        #expect(options.kinds == [.lowTextContrast, .overlappingSiblings])
        #expect(options.excludedKinds == [.childOutsideParent])
    }

    @Test func rejectsUnknownKindFilter() {
        #expect(throws: (any Error).self) {
            _ = try AuditOptions([
                "/tmp/snapshot.json",
                "--kind", "notReal",
            ])
        }
    }
}

import XCTest
@testable import LoupeCore

final class InjectorPathResolverTests: XCTestCase {
    func testResolvePrefersExplicitEnvironmentPath() {
        let resolver = LoupeInjectorPathResolver(
            environment: ["LOUPE_INJECTOR_PATH": "/tmp/custom/LoupeInjector"],
            executableURL: URL(fileURLWithPath: "/opt/homebrew/Cellar/loupe/0.1.0/bin/loupe"),
            fileExists: { $0 == "/tmp/custom/LoupeInjector" }
        )

        XCTAssertEqual(resolver.resolve(), "/tmp/custom/LoupeInjector")
    }

    func testResolveFindsHomebrewCellarRelativeInjector() {
        let expected = "/opt/homebrew/Cellar/loupe/0.1.0/libexec/LoupeInjector.framework/LoupeInjector"
        let resolver = LoupeInjectorPathResolver(
            environment: [:],
            executableURL: URL(fileURLWithPath: "/opt/homebrew/Cellar/loupe/0.1.0/bin/loupe"),
            fileExists: { $0 == expected }
        )

        XCTAssertEqual(resolver.resolve(), expected)
    }

    func testResolveFallsBackToHomebrewOptPath() {
        let expected = "/opt/homebrew/opt/loupe/libexec/LoupeInjector.framework/LoupeInjector"
        let resolver = LoupeInjectorPathResolver(
            environment: [:],
            executableURL: nil,
            fileExists: { $0 == expected }
        )

        XCTAssertEqual(resolver.resolve(), expected)
    }
}

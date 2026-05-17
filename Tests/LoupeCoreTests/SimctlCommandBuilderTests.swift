import XCTest
@testable import LoupeCore

final class SimctlCommandBuilderTests: XCTestCase {
    func testLaunchArgumentsPutDeviceBeforeBundleID() {
        let request = SimctlLaunchRequest(
            device: "booted",
            bundleID: "com.example.App",
            environment: [
                "Z_FLAG": "1",
                "DYLD_INSERT_LIBRARIES": "/tmp/libProbe.dylib",
            ]
        )

        XCTAssertEqual(
            SimctlCommandBuilder.launchArguments(for: request),
            [
                "simctl",
                "launch",
                "booted",
                "com.example.App",
            ]
        )
    }

    func testLaunchEnvironmentUsesSIMCTLChildPrefix() {
        let request = SimctlLaunchRequest(
            bundleID: "com.example.App",
            environment: [
                "DYLD_INSERT_LIBRARIES": "/tmp/libProbe.dylib",
            ]
        )

        XCTAssertEqual(
            SimctlCommandBuilder.launchEnvironment(for: request, inheriting: [:]),
            [
                "SIMCTL_CHILD_DYLD_INSERT_LIBRARIES": "/tmp/libProbe.dylib",
            ]
        )
    }
}

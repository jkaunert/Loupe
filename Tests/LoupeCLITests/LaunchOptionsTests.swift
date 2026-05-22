@testable import LoupeCLI
import Testing

@Suite struct LaunchOptionsTests {
    @Test func udidAliasesDevice() throws {
        let options = try LaunchOptions([
            "--bundle-id", "com.apple.Preferences",
            "--udid", "SIM-UDID",
        ])

        #expect(options.device == "SIM-UDID")
    }

    @Test func terminateTimeoutDefaultsToLaunchTimeout() {
        #expect(LoupeCLI.simctlTerminateTimeout(launchTimeout: 12, environment: [:]) == 12)
    }

    @Test func terminateTimeoutCanUseEnvironmentOverride() {
        #expect(
            LoupeCLI.simctlTerminateTimeout(
                launchTimeout: 12,
                environment: ["LOUPE_SIMCTL_TERMINATE_TIMEOUT": "25"]
            ) == 25
        )
    }

    @Test func invalidTerminateTimeoutFallsBackToLaunchTimeout() {
        #expect(
            LoupeCLI.simctlTerminateTimeout(
                launchTimeout: 12,
                environment: ["LOUPE_SIMCTL_TERMINATE_TIMEOUT": "0"]
            ) == 12
        )
        #expect(
            LoupeCLI.simctlTerminateTimeout(
                launchTimeout: 12,
                environment: ["LOUPE_SIMCTL_TERMINATE_TIMEOUT": "nope"]
            ) == 12
        )
    }
}

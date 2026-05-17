import Foundation

public struct SimctlLaunchRequest: Equatable {
    public var device: String
    public var bundleID: String
    public var environment: [String: String]

    public init(
        device: String = "booted",
        bundleID: String,
        environment: [String: String] = [:]
    ) {
        self.device = device
        self.bundleID = bundleID
        self.environment = environment
    }
}

public enum SimctlCommandBuilder {
    public static func launchArguments(for request: SimctlLaunchRequest) -> [String] {
        ["simctl", "launch", request.device, request.bundleID]
    }

    public static func launchEnvironment(
        for request: SimctlLaunchRequest,
        inheriting environment: [String: String] = ProcessInfo.processInfo.environment
    ) -> [String: String] {
        var output = environment
        for key in request.environment.keys.sorted() {
            if let value = request.environment[key] {
                output["SIMCTL_CHILD_\(key)"] = value
            }
        }

        return output
    }
}

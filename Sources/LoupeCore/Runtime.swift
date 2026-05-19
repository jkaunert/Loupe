import Foundation

public struct LoupeRuntimeLog: Codable, Equatable {
    public var id: String
    public var timestamp: Date
    public var level: String
    public var message: String
    public var metadata: [String: LoupeMetadataValue]

    public init(
        id: String = UUID().uuidString,
        timestamp: Date = Date(),
        level: String,
        message: String,
        metadata: [String: LoupeMetadataValue] = [:]
    ) {
        self.id = id
        self.timestamp = timestamp
        self.level = level
        self.message = message
        self.metadata = metadata
    }
}

public struct LoupeRuntimeIdentity: Codable, Equatable {
    public var launchID: String
    public var startedAt: Date
    public var bundleIdentifier: String?
    public var processIdentifier: Int32
    public var simulatorUDID: String?
    public var simulatorName: String?

    public init(
        launchID: String = UUID().uuidString,
        startedAt: Date = Date(),
        bundleIdentifier: String? = nil,
        processIdentifier: Int32,
        simulatorUDID: String? = nil,
        simulatorName: String? = nil
    ) {
        self.launchID = launchID
        self.startedAt = startedAt
        self.bundleIdentifier = bundleIdentifier
        self.processIdentifier = processIdentifier
        self.simulatorUDID = simulatorUDID
        self.simulatorName = simulatorName
    }
}

public struct LoupeRuntimeState: Codable, Equatable {
    public var identity: LoupeRuntimeIdentity
    public var logs: [LoupeRuntimeLog]

    public init(
        identity: LoupeRuntimeIdentity,
        logs: [LoupeRuntimeLog] = []
    ) {
        self.identity = identity
        self.logs = logs
    }
}

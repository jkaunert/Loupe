import Foundation
import LoupeCore

struct ExploreRouteCandidate: Codable, Equatable {
    var ref: String
    var typeName: String
    var role: String?
    var testID: String?
    var text: String?
    var frame: LoupeRect
    var center: LoupePoint
    var reason: String
    var key: String
}

struct ExploreRouteVisit: Codable, Equatable {
    var index: Int
    var candidate: ExploreRouteCandidate
    var beforeSnapshotID: String
    var afterSnapshotID: String?
    var beforeTitle: String?
    var afterTitle: String?
    var tapElapsed: Double
    var afterSnapshotElapsed: Double
    var backElapsed: Double
    var backSucceeded: Bool
    var traceDirectory: String?
    var error: String?
}

struct ExploreRoutesReport: Codable, Equatable {
    var bundleID: String?
    var host: String
    var udid: String
    var screen: LoupeScreen
    var visited: [ExploreRouteVisit]
    var skippedCandidates: Int
    var generatedAt: Date
}


import Foundation
import LoupeCLIModel
import LoupeCore

struct RuntimeListRow: Codable {
    var udid: String
    var simulator: String
    var bundleID: String
    var host: String
    var pid: String
    var live: Bool
    var startedAt: String
    var updatedAt: String
}

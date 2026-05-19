import Foundation
import LoupeCLIModel
import LoupeCore

struct LoupeRuntimeHostRecord: Codable {
    var udid: String
    var bundleID: String
    var host: String
    var updatedAt: Date
}

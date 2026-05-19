import Foundation
import LoupeCLIModel
import LoupeCore

struct LoupeSnapshotDiff: Codable {
    var beforeSnapshotID: String
    var afterSnapshotID: String
    var appeared: [LoupeNodeDiffSummary]
    var disappeared: [LoupeNodeDiffSummary]
    var changed: [LoupeNodeChange]
}

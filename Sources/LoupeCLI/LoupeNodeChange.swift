import Foundation
import LoupeCLIModel
import LoupeCore

struct LoupeNodeChange: Codable {
    var key: String
    var summary: String
    var changes: [LoupeNodeFieldChange]
}

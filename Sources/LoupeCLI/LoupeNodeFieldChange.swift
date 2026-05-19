import Foundation
import LoupeCLIModel
import LoupeCore

struct LoupeNodeFieldChange: Codable {
    var field: String
    var before: String?
    var after: String?
}

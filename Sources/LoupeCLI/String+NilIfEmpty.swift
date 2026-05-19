import Foundation
import LoupeCLIModel
import LoupeCore

extension String {
    var nilIfEmpty: String? {
        isEmpty ? nil : self
    }
}

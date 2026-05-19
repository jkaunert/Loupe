import Foundation
import LoupeCLIModel
import LoupeCore

final class LaunchPortProbe: @unchecked Sendable {
    var result: Result<LoupeRuntimeState, Error>?
}

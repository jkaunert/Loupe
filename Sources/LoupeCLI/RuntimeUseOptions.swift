import Foundation
import LoupeCLIModel
import LoupeCore

struct RuntimeUseOptions {
    var host: URL?
    var bundleID: String?
    var udid: String?
    var timeout: TimeInterval

    init(_ arguments: [String]) throws {
        host = nil
        bundleID = nil
        udid = nil
        timeout = 2
        var index = 0
        while index < arguments.count {
            switch arguments[index] {
            case let value where !value.hasPrefix("--") && bundleID == nil:
                bundleID = value
            case "--host":
                let raw = try Self.value(after: "--host", in: arguments, index: &index)
                guard let url = URL(string: raw) else {
                    throw CLIError("Invalid --host URL: \(raw)")
                }
                host = url
            case "--bundle-id":
                bundleID = try Self.value(after: "--bundle-id", in: arguments, index: &index)
            case "--udid", "--device":
                udid = try Self.value(after: arguments[index], in: arguments, index: &index)
            case "--timeout":
                timeout = try Self.double(after: "--timeout", in: arguments, index: &index)
            default:
                throw CLIError("Unknown use option: \(arguments[index])")
            }
            index += 1
        }
        guard timeout > 0 else {
            throw CLIError("--timeout must be greater than 0")
        }
    }

    private static func value(after option: String, in arguments: [String], index: inout Int) throws -> String {
        let valueIndex = index + 1
        guard valueIndex < arguments.count else {
            throw CLIError("\(option) requires a value")
        }
        index = valueIndex
        return arguments[valueIndex]
    }

    private static func double(after option: String, in arguments: [String], index: inout Int) throws -> Double {
        let raw = try value(after: option, in: arguments, index: &index)
        guard let value = Double(raw) else {
            throw CLIError("\(option) expects a number")
        }
        return value
    }
}

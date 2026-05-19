import Foundation
import LoupeCLIModel
import LoupeCore

struct FetchOptions {
    var url: URL
    var outputURL: URL?
    var timeout: TimeInterval

    init(_ arguments: [String]) throws {
        guard let rawURL = arguments.first, !rawURL.hasPrefix("--") else {
            throw CLIError("Usage: loupe fetch <url> [--output <path>]")
        }

        guard let url = URL(string: rawURL) else {
            throw CLIError("Invalid URL: \(rawURL)")
        }

        var outputURL: URL?
        var timeout: TimeInterval = 5
        var index = 1

        while index < arguments.count {
            switch arguments[index] {
            case "--output":
                let value = try Self.value(after: "--output", in: arguments, index: &index)
                outputURL = URL(fileURLWithPath: value)
            case "--timeout":
                timeout = try Self.double(after: "--timeout", in: arguments, index: &index)
            default:
                throw CLIError("Unknown fetch option: \(arguments[index])")
            }

            index += 1
        }

        self.url = url
        self.outputURL = outputURL
        guard timeout > 0 else {
            throw CLIError("--timeout must be greater than 0")
        }
        self.timeout = timeout
    }

    private static func value(
        after option: String,
        in arguments: [String],
        index: inout Int
    ) throws -> String {
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

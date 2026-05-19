import Foundation
import LoupeCLIModel
import LoupeCore

struct CleanupOptions {
    var dryRun: Bool
    var pruneRuntimes: Bool
    var pruneTraces: Bool
    var tracesOlderThan: TimeInterval
    var recordingsOlderThan: TimeInterval?
    var timeout: TimeInterval

    init(_ arguments: [String]) throws {
        dryRun = false
        pruneRuntimes = true
        pruneTraces = true
        tracesOlderThan = 7 * 24 * 60 * 60
        recordingsOlderThan = nil
        timeout = 1

        var index = 0
        while index < arguments.count {
            switch arguments[index] {
            case "--dry-run":
                dryRun = true
            case "--no-runtimes":
                pruneRuntimes = false
            case "--no-traces":
                pruneTraces = false
            case "--traces-older-than":
                tracesOlderThan = try Self.duration(after: "--traces-older-than", in: arguments, index: &index)
            case "--all-traces":
                tracesOlderThan = 0
            case "--recordings-older-than":
                recordingsOlderThan = try Self.duration(after: "--recordings-older-than", in: arguments, index: &index)
            case "--include-recordings":
                recordingsOlderThan = 30 * 24 * 60 * 60
            case "--timeout":
                timeout = try Self.double(after: "--timeout", in: arguments, index: &index)
            default:
                throw CLIError("Unknown cleanup option: \(arguments[index])")
            }
            index += 1
        }
    }

    private static func duration(after option: String, in arguments: [String], index: inout Int) throws -> TimeInterval {
        let raw = try value(after: option, in: arguments, index: &index)
        return try parseDuration(raw, option: option)
    }

    private static func double(after option: String, in arguments: [String], index: inout Int) throws -> Double {
        let raw = try value(after: option, in: arguments, index: &index)
        guard let value = Double(raw), value >= 0 else {
            throw CLIError("\(option) expects a non-negative number")
        }
        return value
    }

    private static func value(after option: String, in arguments: [String], index: inout Int) throws -> String {
        let valueIndex = index + 1
        guard valueIndex < arguments.count else {
            throw CLIError("\(option) requires a value")
        }
        index = valueIndex
        return arguments[valueIndex]
    }

    private static func parseDuration(_ rawValue: String, option: String) throws -> TimeInterval {
        let raw = rawValue.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard !raw.isEmpty else {
            throw CLIError("\(option) expects a duration like 7d, 12h, 30m, or 60s")
        }

        let unit = raw.last.flatMap { character -> Character? in
            character.isLetter ? character : nil
        }
        let numberPart = unit == nil ? raw : String(raw.dropLast())
        guard let value = Double(numberPart), value >= 0 else {
            throw CLIError("\(option) expects a non-negative duration")
        }

        switch unit {
        case nil, "s":
            return value
        case "m":
            return value * 60
        case "h":
            return value * 60 * 60
        case "d":
            return value * 24 * 60 * 60
        default:
            throw CLIError("\(option) duration unit must be s, m, h, or d")
        }
    }
}

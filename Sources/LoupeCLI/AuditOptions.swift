import Foundation
import LoupeCLIModel
import LoupeCore

struct AuditOptions {
    var snapshotURL: URL
    var tolerance: Double
    var minOverlapArea: Double
    var minTouchTarget: Double
    var minContrastRatio: Double

    init(_ arguments: [String]) throws {
        guard let path = arguments.first, !path.hasPrefix("--") else {
            throw CLIError("Usage: loupe audit <snapshot.json> [--tolerance <points>] [--min-overlap-area <points2>] [--min-touch-target <points>] [--min-contrast-ratio <ratio>]")
        }

        snapshotURL = URL(fileURLWithPath: path)
        tolerance = 1
        minOverlapArea = 16
        minTouchTarget = 44
        minContrastRatio = 4.5

        var index = 1
        while index < arguments.count {
            switch arguments[index] {
            case "--tolerance":
                tolerance = try Self.double(after: "--tolerance", in: arguments, index: &index)
            case "--min-overlap-area":
                minOverlapArea = try Self.double(after: "--min-overlap-area", in: arguments, index: &index)
            case "--min-touch-target":
                minTouchTarget = try Self.double(after: "--min-touch-target", in: arguments, index: &index)
            case "--min-contrast-ratio":
                minContrastRatio = try Self.double(after: "--min-contrast-ratio", in: arguments, index: &index)
            default:
                throw CLIError("Unknown audit option: \(arguments[index])")
            }
            index += 1
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

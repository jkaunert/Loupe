import Foundation
import LoupeCLIModel
import LoupeCore

struct InstallSkillsOptions {
    var target: SkillInstallTargetSelection
    var sourceURL: URL?

    init(_ arguments: [String]) throws {
        target = .all
        sourceURL = nil

        var index = 0
        while index < arguments.count {
            switch arguments[index] {
            case "--target":
                let raw = try Self.value(after: "--target", in: arguments, index: &index)
                guard let parsed = SkillInstallTargetSelection(rawValue: raw) else {
                    throw CLIError("--target expects all, codex, or claude")
                }
                target = parsed
            case "--source":
                let raw = try Self.value(after: "--source", in: arguments, index: &index)
                sourceURL = URL(fileURLWithPath: raw, isDirectory: true)
            default:
                throw CLIError("Unknown skills install option: \(arguments[index])")
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
}

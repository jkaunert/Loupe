import Foundation
import LoupeCLIModel
import LoupeCore

struct TreeOptions {
    var snapshotURL: URL?
    var host: URL
    var hostWasExplicit: Bool
    var udid: String?
    var bundleID: String?
    var selector: LoupeSelector?
    var includeHidden: Bool
    var depth: Int?
    var timeout: TimeInterval
    var tree: QueryTree
    var presentation: TreePresentation

    init(_ arguments: [String]) throws {
        snapshotURL = nil
        host = URL(string: "http://127.0.0.1:8765")!
        hostWasExplicit = false
        udid = nil
        bundleID = nil
        selector = nil
        includeHidden = false
        depth = nil
        timeout = 5
        tree = .view
        presentation = .outline

        var index = 0
        if let first = arguments.first, !first.hasPrefix("--") {
            snapshotURL = URL(fileURLWithPath: first)
            index = 1
        }

        while index < arguments.count {
            switch arguments[index] {
            case "--host":
                let raw = try Self.value(after: "--host", in: arguments, index: &index)
                guard let url = URL(string: raw) else {
                    throw CLIError("Invalid --host URL: \(raw)")
                }
                host = url
                hostWasExplicit = true
            case "--udid", "--device":
                udid = try Self.value(after: arguments[index], in: arguments, index: &index)
            case "--bundle-id":
                bundleID = try Self.value(after: "--bundle-id", in: arguments, index: &index)
            case "--view":
                tree = .view
            case "--accessibility":
                tree = .accessibility
            case "--interesting":
                presentation = .interesting
            case "--visible-leaves":
                presentation = .visibleLeaves
            case "--mutable":
                presentation = .mutable
                tree = .view
            case "--tree":
                let rawValue = try Self.value(after: "--tree", in: arguments, index: &index)
                guard let value = QueryTree(rawValue: rawValue) else {
                    throw CLIError("--tree expects view or accessibility")
                }
                tree = value
            case "--test-id":
                selector = .testID(try Self.value(after: "--test-id", in: arguments, index: &index))
            case "--text":
                if index + 1 < arguments.count, !arguments[index + 1].hasPrefix("--") {
                    selector = .text(try Self.value(after: "--text", in: arguments, index: &index), exact: false)
                } else {
                    presentation = .text
                }
            case "--exact-text":
                selector = .text(try Self.value(after: "--exact-text", in: arguments, index: &index), exact: true)
            case "--role":
                selector = .role(try Self.value(after: "--role", in: arguments, index: &index))
            case "--ref":
                selector = .ref(try Self.value(after: "--ref", in: arguments, index: &index))
            case "--depth":
                let raw = try Self.value(after: "--depth", in: arguments, index: &index)
                guard let value = Int(raw), value >= 0 else {
                    throw CLIError("--depth expects a non-negative integer")
                }
                depth = value
            case "--include-hidden":
                includeHidden = true
            case "--timeout":
                timeout = try Self.double(after: "--timeout", in: arguments, index: &index)
            default:
                throw CLIError("Unknown tree option: \(arguments[index])")
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

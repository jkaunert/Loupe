import Foundation
import LoupeCLIModel
import LoupeCore

struct ReplayOptions {
    var recordingURL: URL
    var host: URL
    var hostWasExplicit: Bool
    var udid: String
    var screen: LoupeSize
    var actionOptions: ReplayActionOptions

    init(_ arguments: [String]) throws {
        guard let path = arguments.first, !path.hasPrefix("--") else {
            throw CLIError("Usage: loupe replay <recording.json|alias> --udid <sim> --width <points> --height <points> [--host <url>] [--backend auto|native]")
        }

        let fileURL = URL(fileURLWithPath: path)
        recordingURL = FileManager.default.fileExists(atPath: fileURL.path) ? fileURL : Self.recordingURL(alias: path)
        var host = URL(string: "http://127.0.0.1:8765")!
        var hostWasExplicit = false
        var backend = "auto"
        var udid = "booted"
        var width: Double?
        var height: Double?
        var index = 1

        while index < arguments.count {
            switch arguments[index] {
            case "--host":
                host = try Self.url(after: "--host", in: arguments, index: &index)
                hostWasExplicit = true
            case "--backend":
                backend = try Self.value(after: "--backend", in: arguments, index: &index)
            case "--udid", "--device":
                udid = try Self.value(after: arguments[index], in: arguments, index: &index)
            case "--width":
                width = try Self.double(after: "--width", in: arguments, index: &index)
            case "--height":
                height = try Self.double(after: "--height", in: arguments, index: &index)
            default:
                throw CLIError("Unknown replay option: \(arguments[index])")
            }
            index += 1
        }

        guard let width, let height else {
            throw CLIError("replay requires --width and --height in device points")
        }

        self.host = host
        self.hostWasExplicit = hostWasExplicit
        self.udid = udid
        screen = LoupeSize(width: width, height: height)
        actionOptions = ReplayActionOptions(
            backend: backend,
            udid: udid,
            timeout: 8,
            endPoint: nil,
            duration: nil,
            text: nil,
            startSpread: nil,
            endSpread: nil,
            traceDirectory: nil
        )
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

    private static func url(after option: String, in arguments: [String], index: inout Int) throws -> URL {
        let raw = try value(after: option, in: arguments, index: &index)
        guard let url = URL(string: raw) else {
            throw CLIError("Invalid URL for \(option): \(raw)")
        }
        return url
    }

    private static func recordingURL(alias: String) -> URL {
        FileManager.default.homeDirectoryForCurrentUser
            .appendingPathComponent(".loupe", isDirectory: true)
            .appendingPathComponent("recordings", isDirectory: true)
            .appendingPathComponent("\(sanitizedAlias(alias)).json")
    }

    private static func sanitizedAlias(_ alias: String) -> String {
        let allowed = CharacterSet.alphanumerics.union(CharacterSet(charactersIn: "-_."))
        return alias.unicodeScalars
            .map { allowed.contains($0) ? Character($0) : "-" }
            .map(String.init)
            .joined()
    }
}

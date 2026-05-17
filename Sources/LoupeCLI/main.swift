import Foundation
import LoupeCore

@main
struct LoupeCLI {
    static func main() async throws {
        var arguments = Array(CommandLine.arguments.dropFirst())
        let command = arguments.isEmpty ? "help" : arguments.removeFirst()

        switch command {
        case "compact":
            try compact(arguments)
        case "doctor":
            try doctor(arguments)
        case "fetch":
            try await fetch(arguments)
        case "injector-path":
            try injectorPath(arguments)
        case "query":
            try query(arguments)
        case "launch":
            try launch(arguments)
        case "help", "--help", "-h":
            printHelp()
        default:
            throw CLIError("Unknown command: \(command)")
        }
    }

    private static func compact(_ arguments: [String]) throws {
        guard arguments.count == 1 else {
            throw CLIError("Usage: loupe compact <snapshot.json>")
        }

        let url = URL(fileURLWithPath: arguments[0])
        let data = try Data(contentsOf: url)
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        let snapshot = try decoder.decode(LoupeSnapshot.self, from: data)
        let observation = LoupeObservationCompactor.compact(snapshot)

        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        encoder.dateEncodingStrategy = .iso8601
        FileHandle.standardOutput.write(try encoder.encode(observation))
        FileHandle.standardOutput.write(Data("\n".utf8))
    }

    private static func query(_ arguments: [String]) throws {
        let options = try QueryOptions(arguments)
        let data = try Data(contentsOf: options.snapshotURL)
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let snapshot = try decoder.decode(LoupeSnapshot.self, from: data)

        let results = LoupeSnapshotQuery.find(
            options.selector,
            in: snapshot,
            options: LoupeQueryOptions(
                includeHidden: options.includeHidden,
                includeDisabled: true,
                maxResults: options.maxResults
            )
        )

        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        FileHandle.standardOutput.write(try encoder.encode(results))
        FileHandle.standardOutput.write(Data("\n".utf8))
    }

    private static func launch(_ arguments: [String]) throws {
        let options = try LaunchOptions(arguments)
        var environment = options.environment

        if options.shouldInject, let dylibPath = try resolvedInjectorPath(explicitPath: options.dylibPath) {
            environment["DYLD_INSERT_LIBRARIES"] = dylibPath
        }

        let request = SimctlLaunchRequest(
            device: options.device,
            bundleID: options.bundleID,
            environment: environment
        )

        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/xcrun")
        process.arguments = SimctlCommandBuilder.launchArguments(for: request)
        process.environment = SimctlCommandBuilder.launchEnvironment(for: request)

        try process.run()
        process.waitUntilExit()

        guard process.terminationStatus == 0 else {
            throw CLIError("simctl launch exited with status \(process.terminationStatus)")
        }
    }

    private static func injectorPath(_ arguments: [String]) throws {
        guard arguments.isEmpty else {
            throw CLIError("Usage: loupe injector-path")
        }

        guard let path = try resolvedInjectorPath(explicitPath: nil) else {
            throw CLIError("LoupeInjector not found. Set LOUPE_INJECTOR_PATH or install Loupe through Homebrew.")
        }

        print(path)
    }

    private static func doctor(_ arguments: [String]) throws {
        guard arguments.isEmpty else {
            throw CLIError("Usage: loupe doctor")
        }

        print("loupe: ok")

        if let path = try resolvedInjectorPath(explicitPath: nil) {
            print("injector: \(path)")
        } else {
            print("injector: not found")
            print("hint: set LOUPE_INJECTOR_PATH or install via Homebrew")
        }

        let simctl = Process()
        simctl.executableURL = URL(fileURLWithPath: "/usr/bin/xcrun")
        simctl.arguments = ["simctl", "help"]
        try simctl.run()
        simctl.waitUntilExit()
        print("simctl: \(simctl.terminationStatus == 0 ? "ok" : "unavailable")")
    }

    private static func resolvedInjectorPath(explicitPath: String?) throws -> String? {
        if let explicitPath {
            guard FileManager.default.isExecutableFile(atPath: explicitPath) else {
                throw CLIError("Injector is not executable: \(explicitPath)")
            }
            return explicitPath
        }

        return LoupeInjectorPathResolver().resolve()
    }

    private static func fetch(_ arguments: [String]) async throws {
        let options = try FetchOptions(arguments)
        let (data, response) = try await URLSession.shared.data(from: options.url)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw CLIError("fetch expected an HTTP response")
        }

        guard (200..<300).contains(httpResponse.statusCode) else {
            throw CLIError("fetch failed with HTTP \(httpResponse.statusCode)")
        }

        if let outputURL = options.outputURL {
            try data.write(to: outputURL)
        } else {
            FileHandle.standardOutput.write(data)
            FileHandle.standardOutput.write(Data("\n".utf8))
        }
    }

    private static func printHelp() {
        print(
            """
            loupe

            Commands:
              compact <snapshot.json>
                  Print the LLM-facing compact observation for a full app snapshot.

              doctor
                  Check local Loupe installation and injector discovery.

              fetch <url> [--output <path>]
                  Fetch a probe endpoint such as http://127.0.0.1:8765/observation.

              injector-path
                  Print the LoupeInjector executable path used for simulator injection.

              query <snapshot.json> (--test-id <id> | --text <text> | --role <role> | --ref <ref>)
                  Query a full snapshot and print matching node summaries.

              launch --bundle-id <id> [--device booted] [--inject] [--dylib <path>] [--env KEY=VALUE]
                  Launch an iOS Simulator app through simctl. --inject auto-resolves LoupeInjector.
            """
        )
    }
}

private struct QueryOptions {
    var snapshotURL: URL
    var selector: LoupeSelector
    var includeHidden: Bool
    var maxResults: Int

    init(_ arguments: [String]) throws {
        guard let path = arguments.first, !path.hasPrefix("--") else {
            throw CLIError("Usage: loupe query <snapshot.json> (--test-id <id> | --text <text> | --role <role> | --ref <ref>)")
        }

        snapshotURL = URL(fileURLWithPath: path)
        includeHidden = false
        maxResults = 50

        var selector: LoupeSelector?
        var index = 1

        while index < arguments.count {
            switch arguments[index] {
            case "--test-id":
                selector = .testID(try Self.value(after: "--test-id", in: arguments, index: &index))
            case "--text":
                selector = .text(try Self.value(after: "--text", in: arguments, index: &index), exact: false)
            case "--exact-text":
                selector = .text(try Self.value(after: "--exact-text", in: arguments, index: &index), exact: true)
            case "--role":
                selector = .role(try Self.value(after: "--role", in: arguments, index: &index))
            case "--ref":
                selector = .ref(try Self.value(after: "--ref", in: arguments, index: &index))
            case "--include-hidden":
                includeHidden = true
            case "--max-results":
                let rawValue = try Self.value(after: "--max-results", in: arguments, index: &index)
                guard let value = Int(rawValue), value > 0 else {
                    throw CLIError("--max-results expects a positive integer")
                }
                maxResults = value
            default:
                throw CLIError("Unknown query option: \(arguments[index])")
            }

            index += 1
        }

        guard let selector else {
            throw CLIError("query requires one selector option")
        }

        self.selector = selector
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
}

private struct FetchOptions {
    var url: URL
    var outputURL: URL?

    init(_ arguments: [String]) throws {
        guard let rawURL = arguments.first, !rawURL.hasPrefix("--") else {
            throw CLIError("Usage: loupe fetch <url> [--output <path>]")
        }

        guard let url = URL(string: rawURL) else {
            throw CLIError("Invalid URL: \(rawURL)")
        }

        var outputURL: URL?
        var index = 1

        while index < arguments.count {
            switch arguments[index] {
            case "--output":
                let value = try Self.value(after: "--output", in: arguments, index: &index)
                outputURL = URL(fileURLWithPath: value)
            default:
                throw CLIError("Unknown fetch option: \(arguments[index])")
            }

            index += 1
        }

        self.url = url
        self.outputURL = outputURL
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
}

private struct LaunchOptions {
    var bundleID: String
    var device: String
    var dylibPath: String?
    var environment: [String: String]
    var shouldInject: Bool

    init(_ arguments: [String]) throws {
        var bundleID: String?
        var device = "booted"
        var dylibPath: String?
        var environment: [String: String] = [:]
        var shouldInject = false
        var index = 0

        while index < arguments.count {
            let argument = arguments[index]

            switch argument {
            case "--bundle-id":
                bundleID = try Self.value(after: argument, in: arguments, index: &index)
            case "--device":
                device = try Self.value(after: argument, in: arguments, index: &index)
            case "--dylib":
                dylibPath = try Self.value(after: argument, in: arguments, index: &index)
                shouldInject = true
            case "--inject":
                shouldInject = true
            case "--env":
                let pair = try Self.value(after: argument, in: arguments, index: &index)
                let pieces = pair.split(separator: "=", maxSplits: 1).map(String.init)
                guard pieces.count == 2 else {
                    throw CLIError("--env expects KEY=VALUE")
                }
                environment[pieces[0]] = pieces[1]
            default:
                throw CLIError("Unknown launch option: \(argument)")
            }

            index += 1
        }

        guard let bundleID else {
            throw CLIError("launch requires --bundle-id <id>")
        }

        self.bundleID = bundleID
        self.device = device
        self.dylibPath = dylibPath
        self.environment = environment
        self.shouldInject = shouldInject
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
}

private struct CLIError: Error, CustomStringConvertible {
    var description: String

    init(_ description: String) {
        self.description = description
    }
}

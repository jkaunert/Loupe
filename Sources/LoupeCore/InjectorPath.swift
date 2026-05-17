import Foundation

public struct LoupeInjectorPathResolver {
    public var environment: [String: String]
    public var executableURL: URL?
    public var extraSearchRoots: [URL]
    public var fileExists: (String) -> Bool

    public init(
        environment: [String: String] = ProcessInfo.processInfo.environment,
        executableURL: URL? = Bundle.main.executableURL,
        extraSearchRoots: [URL] = [],
        fileExists: @escaping (String) -> Bool = { FileManager.default.isExecutableFile(atPath: $0) }
    ) {
        self.environment = environment
        self.executableURL = executableURL
        self.extraSearchRoots = extraSearchRoots
        self.fileExists = fileExists
    }

    public func resolve() -> String? {
        for candidate in candidates() where fileExists(candidate.path) {
            return candidate.path
        }

        return nil
    }

    public func candidates() -> [URL] {
        var candidates: [URL] = []

        if let explicitPath = environment["LOUPE_INJECTOR_PATH"], !explicitPath.isEmpty {
            candidates.append(URL(fileURLWithPath: explicitPath))
        }

        if let executableURL {
            let cellarRoot = executableURL
                .deletingLastPathComponent()
                .deletingLastPathComponent()
            candidates.append(Self.injectorExecutable(in: cellarRoot))
        }

        for root in extraSearchRoots {
            candidates.append(Self.injectorExecutable(in: root))
        }

        candidates.append(URL(fileURLWithPath: "/opt/homebrew/opt/loupe/libexec/LoupeInjector.framework/LoupeInjector"))
        candidates.append(URL(fileURLWithPath: "/usr/local/opt/loupe/libexec/LoupeInjector.framework/LoupeInjector"))

        var seen: Set<String> = []
        return candidates.filter { url in
            let path = url.path
            guard !seen.contains(path) else {
                return false
            }
            seen.insert(path)
            return true
        }
    }

    public static func injectorExecutable(in root: URL) -> URL {
        root
            .appendingPathComponent("libexec")
            .appendingPathComponent("LoupeInjector.framework")
            .appendingPathComponent("LoupeInjector")
    }
}

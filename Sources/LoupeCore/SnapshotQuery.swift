import Foundation

public enum LoupeSelector: Equatable {
    case testID(String)
    case text(String, exact: Bool = true)
    case role(String)
    case roleAndText(role: String, text: String, exact: Bool = true)
    case ref(String)
}

public struct LoupeQueryOptions: Equatable {
    public var includeHidden: Bool
    public var includeDisabled: Bool
    public var maxResults: Int

    public init(
        includeHidden: Bool = false,
        includeDisabled: Bool = true,
        maxResults: Int = 50
    ) {
        self.includeHidden = includeHidden
        self.includeDisabled = includeDisabled
        self.maxResults = maxResults
    }
}

public struct LoupeQueryResult: Codable, Equatable {
    public var ref: String
    public var role: String?
    public var text: String?
    public var testID: String?
    public var frame: LoupeRect?
    public var isVisible: Bool
    public var isEnabled: Bool
    public var isInteractive: Bool

    public init(node: LoupeNode) {
        ref = node.ref
        role = node.role
        text = LoupeObservationCompactor.displayText(for: node)
        testID = node.testID
        frame = node.frame
        isVisible = node.isVisible
        isEnabled = node.isEnabled
        isInteractive = node.isInteractive
    }
}

public enum LoupeSnapshotQuery {
    public static func find(
        _ selector: LoupeSelector,
        in snapshot: LoupeSnapshot,
        options: LoupeQueryOptions = LoupeQueryOptions()
    ) -> [LoupeQueryResult] {
        snapshot.nodes.values
            .filter { matchesVisibilityAndState($0, options: options) }
            .filter { matches(selector, node: $0) }
            .sorted(by: resultOrder)
            .prefix(options.maxResults)
            .map(LoupeQueryResult.init)
    }

    public static func first(
        _ selector: LoupeSelector,
        in snapshot: LoupeSnapshot,
        options: LoupeQueryOptions = LoupeQueryOptions()
    ) -> LoupeQueryResult? {
        find(selector, in: snapshot, options: options).first
    }

    private static func matchesVisibilityAndState(
        _ node: LoupeNode,
        options: LoupeQueryOptions
    ) -> Bool {
        if !options.includeHidden, !node.isVisible {
            return false
        }

        if !options.includeDisabled, !node.isEnabled {
            return false
        }

        return true
    }

    private static func matches(_ selector: LoupeSelector, node: LoupeNode) -> Bool {
        switch selector {
        case let .testID(testID):
            return node.testID == testID || stringMetadata("id", from: node.custom) == testID
        case let .text(text, exact):
            return matchesText(text, exact: exact, node: node)
        case let .role(role):
            return node.role == role
        case let .roleAndText(role, text, exact):
            return node.role == role && matchesText(text, exact: exact, node: node)
        case let .ref(ref):
            return node.ref == ref
        }
    }

    private static func matchesText(
        _ text: String,
        exact: Bool,
        node: LoupeNode
    ) -> Bool {
        guard let displayText = LoupeObservationCompactor.displayText(for: node) else {
            return false
        }

        if exact {
            return displayText == text
        }

        return displayText.localizedCaseInsensitiveContains(text)
    }

    private static func resultOrder(_ lhs: LoupeNode, _ rhs: LoupeNode) -> Bool {
        if lhs.isInteractive != rhs.isInteractive {
            return lhs.isInteractive && !rhs.isInteractive
        }

        guard let lhsFrame = lhs.frame else { return false }
        guard let rhsFrame = rhs.frame else { return true }

        if abs(lhsFrame.y - rhsFrame.y) > 1 {
            return lhsFrame.y < rhsFrame.y
        }

        return lhsFrame.x < rhsFrame.x
    }

    private static func stringMetadata(
        _ key: String,
        from metadata: [String: LoupeMetadataValue]
    ) -> String? {
        guard case let .string(value) = metadata[key] else {
            return nil
        }
        return value
    }
}

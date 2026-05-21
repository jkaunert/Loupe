import Foundation

public struct LoupePaintStackEntry: Codable, Equatable {
    public var ref: String
    public var parentRef: String?
    public var depth: Int
    public var typeName: String
    public var className: String?
    public var role: String?
    public var testID: String?
    public var text: String?
    public var frame: LoupeRect
    public var style: LoupeStyle?
    public var isInteractive: Bool

    public init(
        ref: String,
        parentRef: String?,
        depth: Int,
        typeName: String,
        className: String?,
        role: String?,
        testID: String?,
        text: String?,
        frame: LoupeRect,
        style: LoupeStyle?,
        isInteractive: Bool
    ) {
        self.ref = ref
        self.parentRef = parentRef
        self.depth = depth
        self.typeName = typeName
        self.className = className
        self.role = role
        self.testID = testID
        self.text = text
        self.frame = frame
        self.style = style
        self.isInteractive = isInteractive
    }
}

public struct LoupePaintStack: Codable, Equatable {
    public var snapshotID: String
    public var point: LoupePoint
    public var sourceRef: String?
    public var entries: [LoupePaintStackEntry]

    public init(
        snapshotID: String,
        point: LoupePoint,
        sourceRef: String?,
        entries: [LoupePaintStackEntry]
    ) {
        self.snapshotID = snapshotID
        self.point = point
        self.sourceRef = sourceRef
        self.entries = entries
    }
}

public enum LoupePaintStackBuilder {
    public static func stack(
        in snapshot: LoupeSnapshot,
        at point: LoupePoint,
        sourceRef: String? = nil,
        maxEntries: Int = 50
    ) -> LoupePaintStack {
        let depths = nodeDepths(snapshot)
        let orders = paintOrders(snapshot)
        let entries = snapshot.nodes.values
            .filter { node in
                guard node.isVisible, let frame = node.frame else { return false }
                guard frame.contains(point) else { return false }
                return node.kind == .view || node.kind == .window
            }
            .sorted { lhs, rhs in
                let lhsOrder = orders[lhs.ref] ?? 0
                let rhsOrder = orders[rhs.ref] ?? 0
                if lhsOrder != rhsOrder {
                    return lhsOrder > rhsOrder
                }
                return lhs.ref > rhs.ref
            }
            .prefix(maxEntries)
            .map { node in
                LoupePaintStackEntry(
                    ref: node.ref,
                    parentRef: node.parentRef,
                    depth: depths[node.ref] ?? 0,
                    typeName: node.typeName,
                    className: node.uiKit?.className,
                    role: node.role,
                    testID: node.testID,
                    text: LoupeObservationCompactor.displayText(for: node),
                    frame: node.frame!,
                    style: node.style,
                    isInteractive: node.isInteractive
                )
            }

        return LoupePaintStack(
            snapshotID: snapshot.id,
            point: point,
            sourceRef: sourceRef,
            entries: Array(entries)
        )
    }

    public static func stack(
        in snapshot: LoupeSnapshot,
        centeredOn ref: String,
        maxEntries: Int = 50
    ) throws -> LoupePaintStack {
        guard let node = snapshot.nodes[ref] else {
            throw LoupePaintStackError.missingRef(ref)
        }
        guard let frame = node.frame else {
            throw LoupePaintStackError.missingFrame(ref)
        }
        let point = LoupePoint(x: frame.x + frame.width / 2, y: frame.y + frame.height / 2)
        return stack(in: snapshot, at: point, sourceRef: ref, maxEntries: maxEntries)
    }

    private static func nodeDepths(_ snapshot: LoupeSnapshot) -> [String: Int] {
        var depths: [String: Int] = [:]
        func visit(_ ref: String, depth: Int) {
            guard depths[ref] == nil, let node = snapshot.nodes[ref] else { return }
            depths[ref] = depth
            for child in node.children {
                visit(child, depth: depth + 1)
            }
        }
        for root in snapshot.rootRefs {
            visit(root, depth: 0)
        }
        return depths
    }

    private static func paintOrders(_ snapshot: LoupeSnapshot) -> [String: Int] {
        var order = 0
        var orders: [String: Int] = [:]
        func visit(_ ref: String) {
            guard let node = snapshot.nodes[ref] else { return }
            orders[ref] = order
            order += 1
            for child in node.children {
                visit(child)
            }
        }
        for root in snapshot.rootRefs {
            visit(root)
        }
        return orders
    }
}

public enum LoupePaintStackError: Error, CustomStringConvertible, Equatable {
    case missingRef(String)
    case missingFrame(String)

    public var description: String {
        switch self {
        case let .missingRef(ref):
            return "No Loupe node matched ref \(ref)"
        case let .missingFrame(ref):
            return "Loupe node \(ref) has no frame"
        }
    }
}

public extension LoupeRect {
    func contains(_ point: LoupePoint) -> Bool {
        guard !isEmpty else { return false }
        return point.x >= x && point.x <= maxX && point.y >= y && point.y <= maxY
    }
}

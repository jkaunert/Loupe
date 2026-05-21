import Foundation
import LoupeCore

enum GestureScrollAxis: String, Equatable {
    case horizontal
    case vertical
}

struct GestureScrollBaseline: Equatable {
    var ref: String
    var typeName: String
    var axis: GestureScrollAxis
    var startPoint: LoupePoint
    var beforeOffset: LoupePoint
    var minOffset: Double
    var maxOffset: Double
}

enum GestureScrollVerifier {
    static func baseline(
        in snapshot: LoupeSnapshot,
        start: LoupePoint,
        end: LoupePoint
    ) -> GestureScrollBaseline? {
        let axis: GestureScrollAxis = abs(end.y - start.y) >= abs(end.x - start.x) ? .vertical : .horizontal
        let direction = expectedOffsetDirection(axis: axis, start: start, end: end)

        return snapshot.nodes.values
            .compactMap { node -> (GestureScrollBaseline, Double)? in
                guard node.isVisible,
                      let frame = node.frame,
                      contains(start, in: frame),
                      let scrollView = node.uiKit?.scrollView,
                      scrollView.isScrollEnabled else {
                    return nil
                }
                let range = scrollRange(axis: axis, frame: frame, scrollView: scrollView)
                guard range.max - range.min > 2 else {
                    return nil
                }
                let before = offset(axis: axis, point: scrollView.contentOffset)
                if direction > 0, range.max - before <= 2 {
                    return nil
                }
                if direction < 0, before - range.min <= 2 {
                    return nil
                }
                return (
                    GestureScrollBaseline(
                        ref: node.ref,
                        typeName: node.typeName,
                        axis: axis,
                        startPoint: start,
                        beforeOffset: scrollView.contentOffset,
                        minOffset: range.min,
                        maxOffset: range.max
                    ),
                    frame.width * frame.height
                )
            }
            .sorted { lhs, rhs in lhs.1 < rhs.1 }
            .first?.0
    }

    static func didChange(_ baseline: GestureScrollBaseline, after snapshot: LoupeSnapshot, tolerance: Double = 1) -> Bool {
        guard let scrollView = snapshot.nodes[baseline.ref]?.uiKit?.scrollView else {
            return false
        }
        let before = offset(axis: baseline.axis, point: baseline.beforeOffset)
        let after = offset(axis: baseline.axis, point: scrollView.contentOffset)
        return abs(after - before) > tolerance
    }

    static func diagnostic(_ baseline: GestureScrollBaseline) -> String {
        let axis = baseline.axis.rawValue
        let before = offset(axis: baseline.axis, point: baseline.beforeOffset)
        return "swipe did not change \(axis) scroll offset for \(baseline.ref) \(baseline.typeName) at \(format(baseline.startPoint)). before=\(format(before)) range=\(format(baseline.minOffset))...\(format(baseline.maxOffset)). The start point may be covered by chrome or outside scrollable content; try a point inside visible content or pass --no-verify-scroll."
    }

    private static func expectedOffsetDirection(axis: GestureScrollAxis, start: LoupePoint, end: LoupePoint) -> Double {
        switch axis {
        case .vertical:
            return end.y < start.y ? 1 : -1
        case .horizontal:
            return end.x < start.x ? 1 : -1
        }
    }

    private static func scrollRange(
        axis: GestureScrollAxis,
        frame: LoupeRect,
        scrollView: LoupeUIScrollViewProperties
    ) -> (min: Double, max: Double) {
        switch axis {
        case .vertical:
            let minOffset = -scrollView.adjustedContentInset.top
            let maxOffset = scrollView.contentSize.height - frame.height + scrollView.adjustedContentInset.bottom
            return (minOffset, max(minOffset, maxOffset))
        case .horizontal:
            let minOffset = -scrollView.adjustedContentInset.left
            let maxOffset = scrollView.contentSize.width - frame.width + scrollView.adjustedContentInset.right
            return (minOffset, max(minOffset, maxOffset))
        }
    }

    private static func offset(axis: GestureScrollAxis, point: LoupePoint) -> Double {
        switch axis {
        case .vertical: return point.y
        case .horizontal: return point.x
        }
    }

    private static func contains(_ point: LoupePoint, in frame: LoupeRect) -> Bool {
        point.x >= frame.x && point.x <= frame.maxX && point.y >= frame.y && point.y <= frame.maxY
    }

    private static func format(_ point: LoupePoint) -> String {
        "\(format(point.x)),\(format(point.y))"
    }

    private static func format(_ value: Double) -> String {
        let rounded = (value * 100).rounded() / 100
        if rounded.rounded() == rounded {
            return String(Int(rounded))
        }
        return String(rounded)
    }
}


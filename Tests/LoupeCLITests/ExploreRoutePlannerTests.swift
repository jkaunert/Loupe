@testable import LoupeCLI
import Foundation
import LoupeCore
import Testing

@Suite struct ExploreRoutePlannerTests {
    @Test func selectsVisibleRouteCandidatesInFrameOrder() {
        let snapshot = LoupeSnapshot(
            id: "snapshot",
            capturedAt: Date(timeIntervalSince1970: 0),
            screen: LoupeScreen(size: LoupeSize(width: 390, height: 844), scale: 3),
            rootRefs: ["root"],
            nodes: [
                "root": Self.node("root", typeName: "UIWindow", role: "window", frame: LoupeRect(x: 0, y: 0, width: 390, height: 844), interactive: false),
                "cell2": Self.node("cell2", typeName: "ListCollectionViewCell", role: "cell", frame: LoupeRect(x: 0, y: 200, width: 390, height: 52)),
                "cell1": Self.node("cell1", typeName: "ListCollectionViewCell", role: "cell", frame: LoupeRect(x: 0, y: 120, width: 390, height: 52)),
                "button": Self.node("button", typeName: "UIButton", role: "button", testID: "details", frame: LoupeRect(x: 20, y: 90, width: 80, height: 44)),
                "hidden": Self.node("hidden", typeName: "ListCollectionViewCell", role: "cell", frame: LoupeRect(x: 0, y: 80, width: 390, height: 52), visible: false),
            ]
        )

        let candidates = ExploreRoutePlanner.candidates(in: snapshot)

        #expect(candidates.map(\.ref) == ["cell1", "cell2", "button"])
        #expect(candidates.map(\.reason) == ["cell", "cell", "button"])
    }

    @Test func excludesBackChromeTinyTargetsAndScrollIndicators() {
        let snapshot = LoupeSnapshot(
            id: "snapshot",
            capturedAt: Date(timeIntervalSince1970: 0),
            screen: LoupeScreen(size: LoupeSize(width: 390, height: 844), scale: 3),
            rootRefs: ["root"],
            nodes: [
                "back": Self.node("back", typeName: "UIButton", role: "button", testID: "BackButton", frame: LoupeRect(x: 8, y: 50, width: 44, height: 44)),
                "tiny": Self.node("tiny", typeName: "UIButton", role: "button", frame: LoupeRect(x: 300, y: 50, width: 12, height: 12)),
                "indicator": Self.node("indicator", typeName: "_UIScrollViewScrollIndicator", role: nil, frame: LoupeRect(x: 386, y: 100, width: 3, height: 80)),
                "real": Self.node("real", typeName: "ListCollectionViewCell", role: "cell", frame: LoupeRect(x: 0, y: 180, width: 390, height: 52)),
            ]
        )

        let candidates = ExploreRoutePlanner.candidates(in: snapshot)

        #expect(candidates.map(\.ref) == ["real"])
    }

    @Test func skipsVisitedStableKeys() {
        let snapshot = LoupeSnapshot(
            id: "snapshot",
            capturedAt: Date(timeIntervalSince1970: 0),
            screen: LoupeScreen(size: LoupeSize(width: 390, height: 844), scale: 3),
            rootRefs: ["root"],
            nodes: [
                "first": Self.node("first", typeName: "ListCollectionViewCell", role: "cell", testID: "first.cell", frame: LoupeRect(x: 0, y: 120, width: 390, height: 52)),
                "second": Self.node("second", typeName: "ListCollectionViewCell", role: "cell", testID: "second.cell", frame: LoupeRect(x: 0, y: 180, width: 390, height: 52)),
            ]
        )
        let first = ExploreRoutePlanner.candidates(in: snapshot).first!

        let candidates = ExploreRoutePlanner.candidates(in: snapshot, visitedKeys: [first.key])

        #expect(candidates.map(\.ref) == ["second"])
    }

    private static func node(
        _ ref: String,
        typeName: String,
        role: String?,
        testID: String? = nil,
        frame: LoupeRect,
        visible: Bool = true,
        enabled: Bool = true,
        interactive: Bool = true
    ) -> LoupeNode {
        LoupeNode(
            ref: ref,
            parentRef: nil,
            kind: .view,
            typeName: typeName,
            role: role,
            testID: testID,
            frame: frame,
            isVisible: visible,
            isEnabled: enabled,
            isInteractive: interactive
        )
    }
}


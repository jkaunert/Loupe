@testable import LoupeCLI
import Foundation
import LoupeCore
import Testing

@Suite struct GestureScrollVerifierTests {
    @Test func findsScrollableNodeAtGestureStartPoint() {
        let snapshot = Self.snapshot(offsetY: -168)

        let baseline = GestureScrollVerifier.baseline(
            in: snapshot,
            start: LoupePoint(x: 201, y: 680),
            end: LoupePoint(x: 201, y: 190)
        )

        #expect(baseline?.ref == "scroll")
        #expect(baseline?.axis == .vertical)
        #expect(baseline?.beforeOffset == LoupePoint(x: 0, y: -168))
    }

    @Test func reportsChangedOffset() {
        let baseline = GestureScrollVerifier.baseline(
            in: Self.snapshot(offsetY: -168),
            start: LoupePoint(x: 201, y: 680),
            end: LoupePoint(x: 201, y: 190)
        )!

        #expect(GestureScrollVerifier.didChange(baseline, after: Self.snapshot(offsetY: 240)))
        #expect(!GestureScrollVerifier.didChange(baseline, after: Self.snapshot(offsetY: -168)))
    }

    @Test func skipsVerificationWhenAlreadyAtScrollEdge() {
        let snapshot = Self.snapshot(offsetY: 317)

        let baseline = GestureScrollVerifier.baseline(
            in: snapshot,
            start: LoupePoint(x: 201, y: 680),
            end: LoupePoint(x: 201, y: 190)
        )

        #expect(baseline == nil)
    }

    @Test func prefersSmallestScrollableNodeAtGestureStartPoint() {
        var snapshot = Self.snapshot(offsetY: 0)
        snapshot.nodes["nested"] = LoupeNode(
            ref: "nested",
            parentRef: "scroll",
            kind: .view,
            typeName: "UICollectionView",
            role: "collectionView",
            frame: LoupeRect(x: 20, y: 120, width: 200, height: 300),
            isVisible: true,
            isEnabled: true,
            isInteractive: true,
            uiKit: LoupeUIKitProperties(
                className: "UICollectionView",
                tag: 0,
                alpha: 1,
                isHidden: false,
                isOpaque: true,
                clipsToBounds: true,
                userInteractionEnabled: true,
                isFirstResponder: false,
                scrollView: LoupeUIScrollViewProperties(
                    contentOffset: LoupePoint(x: 0, y: 20),
                    contentSize: LoupeSize(width: 200, height: 700),
                    adjustedContentInset: LoupeInsets(top: 0, left: 0, bottom: 0, right: 0),
                    isScrollEnabled: true,
                    alwaysBounceVertical: true,
                    alwaysBounceHorizontal: false
                )
            )
        )

        let baseline = GestureScrollVerifier.baseline(
            in: snapshot,
            start: LoupePoint(x: 100, y: 300),
            end: LoupePoint(x: 100, y: 180)
        )

        #expect(baseline?.ref == "nested")
        #expect(baseline?.beforeOffset == LoupePoint(x: 0, y: 20))
    }

    private static func snapshot(offsetY: Double) -> LoupeSnapshot {
        LoupeSnapshot(
            id: "snapshot",
            capturedAt: Date(timeIntervalSince1970: 0),
            screen: LoupeScreen(size: LoupeSize(width: 402, height: 874), scale: 3),
            rootRefs: ["root"],
            nodes: [
                "root": LoupeNode(
                    ref: "root",
                    parentRef: nil,
                    kind: .view,
                    typeName: "UIWindow",
                    role: "window",
                    frame: LoupeRect(x: 0, y: 0, width: 402, height: 874),
                    isVisible: true,
                    isEnabled: true,
                    isInteractive: false
                ),
                "scroll": LoupeNode(
                    ref: "scroll",
                    parentRef: "root",
                    kind: .view,
                    typeName: "UICollectionView",
                    role: "collectionView",
                    frame: LoupeRect(x: 0, y: 0, width: 402, height: 874),
                    isVisible: true,
                    isEnabled: true,
                    isInteractive: true,
                    uiKit: LoupeUIKitProperties(
                        className: "UICollectionView",
                        tag: 0,
                        alpha: 1,
                        isHidden: false,
                        isOpaque: true,
                        clipsToBounds: true,
                        userInteractionEnabled: true,
                        isFirstResponder: false,
                        scrollView: LoupeUIScrollViewProperties(
                            contentOffset: LoupePoint(x: 0, y: offsetY),
                            contentSize: LoupeSize(width: 402, height: 1105),
                            adjustedContentInset: LoupeInsets(top: 116, left: 0, bottom: 86, right: 0),
                            isScrollEnabled: true,
                            alwaysBounceVertical: true,
                            alwaysBounceHorizontal: false
                        )
                    )
                ),
            ]
        )
    }
}

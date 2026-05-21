import Foundation
import Testing
@testable import LoupeCore

struct LayoutAuditTests {
    @Test func auditReportsOverlappingSiblingsAndChildrenOutsideParents() {
        let snapshot = LoupeSnapshot(
            id: "layout-1",
            capturedAt: Date(timeIntervalSince1970: 0),
            screen: LoupeScreen(size: LoupeSize(width: 390, height: 844), scale: 3),
            rootRefs: ["root"],
            nodes: [
                "root": LoupeNode(
                    ref: "root",
                    parentRef: nil,
                    kind: .view,
                    typeName: "UIView",
                    testID: "root",
                    frame: LoupeRect(x: 0, y: 0, width: 200, height: 200),
                    isVisible: true,
                    isEnabled: true,
                    isInteractive: false,
                    children: ["a", "b", "c"]
                ),
                "a": LoupeNode(
                    ref: "a",
                    parentRef: "root",
                    kind: .view,
                    typeName: "UIView",
                    testID: "card.a",
                    frame: LoupeRect(x: 20, y: 20, width: 80, height: 80),
                    isVisible: true,
                    isEnabled: true,
                    isInteractive: false
                ),
                "b": LoupeNode(
                    ref: "b",
                    parentRef: "root",
                    kind: .view,
                    typeName: "UIView",
                    testID: "card.b",
                    frame: LoupeRect(x: 60, y: 60, width: 80, height: 80),
                    isVisible: true,
                    isEnabled: true,
                    isInteractive: false
                ),
                "c": LoupeNode(
                    ref: "c",
                    parentRef: "root",
                    kind: .view,
                    typeName: "UIView",
                    testID: "card.c",
                    frame: LoupeRect(x: 180, y: 180, width: 60, height: 60),
                    isVisible: true,
                    isEnabled: true,
                    isInteractive: false
                ),
            ]
        )

        let audit = LoupeLayoutAuditor.audit(snapshot)

        #expect(audit.issueCount == 2)
        #expect(audit.issues.contains { $0.kind == .overlappingSiblings })
        #expect(audit.issues.contains { $0.kind == .childOutsideParent })
    }

    @Test func auditReportsInteractiveTargetAndTestIDIssues() {
        let snapshot = LoupeSnapshot(
            id: "layout-2",
            capturedAt: Date(timeIntervalSince1970: 0),
            screen: LoupeScreen(size: LoupeSize(width: 390, height: 844), scale: 3),
            rootRefs: ["root"],
            nodes: [
                "root": LoupeNode(
                    ref: "root",
                    parentRef: nil,
                    kind: .view,
                    typeName: "UIView",
                    frame: LoupeRect(x: 0, y: 0, width: 390, height: 844),
                    isVisible: true,
                    isEnabled: true,
                    isInteractive: false,
                    children: ["small", "missing", "duplicate-a", "duplicate-b", "image-a", "image-b"]
                ),
                "small": button(ref: "small", testID: "small.button", frame: LoupeRect(x: 20, y: 20, width: 30, height: 30)),
                "missing": button(ref: "missing", testID: nil, frame: LoupeRect(x: 20, y: 80, width: 80, height: 44)),
                "duplicate-a": button(ref: "duplicate-a", testID: "duplicate.button", frame: LoupeRect(x: 20, y: 140, width: 80, height: 44)),
                "duplicate-b": button(ref: "duplicate-b", testID: "duplicate.button", frame: LoupeRect(x: 120, y: 140, width: 80, height: 44)),
                "image-a": decorativeImage(ref: "image-a", testID: "chevron.right", frame: LoupeRect(x: 20, y: 210, width: 12, height: 16)),
                "image-b": decorativeImage(ref: "image-b", testID: "chevron.right", frame: LoupeRect(x: 120, y: 210, width: 12, height: 16)),
            ]
        )

        let audit = LoupeLayoutAuditor.audit(snapshot)

        #expect(audit.issues.contains { $0.kind == .smallInteractiveTarget && $0.testID == "small.button" })
        #expect(audit.issues.contains { $0.kind == .missingTestID && $0.ref == "missing" })
        #expect(audit.issues.filter { $0.kind == .duplicateTestID }.count == 2)
        #expect(!audit.issues.contains { $0.kind == .duplicateTestID && $0.testID == "chevron.right" })
    }

    @Test func auditIgnoresDecorativeImageDuplicateAndOverlapNoise() {
        let snapshot = LoupeSnapshot(
            id: "layout-3",
            capturedAt: Date(timeIntervalSince1970: 0),
            screen: LoupeScreen(size: LoupeSize(width: 390, height: 844), scale: 3),
            rootRefs: ["root"],
            nodes: [
                "root": LoupeNode(
                    ref: "root",
                    parentRef: nil,
                    kind: .view,
                    typeName: "UIView",
                    frame: LoupeRect(x: 0, y: 0, width: 390, height: 844),
                    isVisible: true,
                    isEnabled: true,
                    isInteractive: false,
                    children: ["card", "shadow-a", "shadow-b"]
                ),
                "card": LoupeNode(
                    ref: "card",
                    parentRef: "root",
                    kind: .view,
                    typeName: "UIView",
                    testID: "book.card",
                    frame: LoupeRect(x: 20, y: 80, width: 120, height: 180),
                    isVisible: true,
                    isEnabled: true,
                    isInteractive: false
                ),
                "shadow-a": decorativeImage(
                    ref: "shadow-a",
                    testID: "/tmp/App.app/left-shadow.png",
                    frame: LoupeRect(x: 24, y: 80, width: 24, height: 180)
                ),
                "shadow-b": decorativeImage(
                    ref: "shadow-b",
                    testID: "/tmp/App.app/left-shadow.png",
                    frame: LoupeRect(x: 220, y: 80, width: 24, height: 180)
                ),
            ]
        )

        let audit = LoupeLayoutAuditor.audit(snapshot)

        #expect(!audit.issues.contains { $0.kind == .duplicateTestID && $0.testID == "/tmp/App.app/left-shadow.png" })
        #expect(!audit.issues.contains { $0.kind == .overlappingSiblings })
    }

    @Test func auditIgnoresUnidentifiedBackgroundLayerOverlap() {
        let snapshot = LoupeSnapshot(
            id: "layout-4",
            capturedAt: Date(timeIntervalSince1970: 0),
            screen: LoupeScreen(size: LoupeSize(width: 390, height: 844), scale: 3),
            rootRefs: ["root"],
            nodes: [
                "root": LoupeNode(
                    ref: "root",
                    parentRef: nil,
                    kind: .view,
                    typeName: "UIView",
                    frame: LoupeRect(x: 0, y: 0, width: 390, height: 844),
                    isVisible: true,
                    isEnabled: true,
                    isInteractive: false,
                    children: ["background", "title"]
                ),
                "background": LoupeNode(
                    ref: "background",
                    parentRef: "root",
                    kind: .view,
                    typeName: "UIView",
                    frame: LoupeRect(x: 20, y: 80, width: 200, height: 80),
                    isVisible: true,
                    isEnabled: true,
                    isInteractive: false
                ),
                "title": LoupeNode(
                    ref: "title",
                    parentRef: "root",
                    kind: .view,
                    typeName: "UILabel",
                    text: "Reading Now",
                    frame: LoupeRect(x: 40, y: 100, width: 120, height: 24),
                    isVisible: true,
                    isEnabled: true,
                    isInteractive: false
                ),
            ]
        )

        let audit = LoupeLayoutAuditor.audit(snapshot)

        #expect(!audit.issues.contains { $0.kind == .overlappingSiblings })
    }

    private func button(ref: String, testID: String?, frame: LoupeRect) -> LoupeNode {
        LoupeNode(
            ref: ref,
            parentRef: "root",
            kind: .view,
            typeName: "UIButton",
            role: "button",
            testID: testID,
            frame: frame,
            isVisible: true,
            isEnabled: true,
            isInteractive: true,
            uiKit: LoupeUIKitProperties(
                className: "UIButton",
                tag: 0,
                alpha: 1,
                isHidden: false,
                isOpaque: false,
                clipsToBounds: false,
                userInteractionEnabled: true,
                isFirstResponder: false
            )
        )
    }

    private func decorativeImage(ref: String, testID: String, frame: LoupeRect) -> LoupeNode {
        LoupeNode(
            ref: ref,
            parentRef: "root",
            kind: .view,
            typeName: "UIImageView",
            role: "image",
            testID: testID,
            label: "Forward",
            frame: frame,
            isVisible: true,
            isEnabled: true,
            isInteractive: false,
            accessibility: LoupeAccessibility(
                identifier: testID,
                label: "Forward",
                traits: ["image"],
                frame: frame,
                isElement: false
            ),
            uiKit: LoupeUIKitProperties(
                className: "UIImageView",
                tag: 0,
                alpha: 1,
                isHidden: false,
                isOpaque: false,
                clipsToBounds: false,
                userInteractionEnabled: false,
                isFirstResponder: false
            )
        )
    }
}

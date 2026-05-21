import Foundation
import Testing
@testable import LoupeCore

struct PaintStackTests {
    @Test func stackReturnsTopToBottomNodesAtPoint() throws {
        let snapshot = LoupeSnapshot(
            id: "paint-1",
            capturedAt: Date(timeIntervalSince1970: 0),
            screen: LoupeScreen(size: LoupeSize(width: 200, height: 200), scale: 2),
            rootRefs: ["root"],
            nodes: [
                "root": node(ref: "root", parent: nil, frame: LoupeRect(x: 0, y: 0, width: 200, height: 200), children: ["back", "front"]),
                "back": node(ref: "back", parent: "root", frame: LoupeRect(x: 20, y: 20, width: 100, height: 100)),
                "front": node(ref: "front", parent: "root", frame: LoupeRect(x: 40, y: 40, width: 100, height: 100), text: "Front"),
            ]
        )

        let stack = LoupePaintStackBuilder.stack(
            in: snapshot,
            at: LoupePoint(x: 50, y: 50)
        )

        #expect(stack.entries.map(\.ref) == ["front", "back", "root"])
        #expect(stack.entries.first?.text == "Front")
    }

    @Test func stackCanUseRefCenterPoint() throws {
        let snapshot = LoupeSnapshot(
            id: "paint-2",
            capturedAt: Date(timeIntervalSince1970: 0),
            screen: LoupeScreen(size: LoupeSize(width: 200, height: 200), scale: 2),
            rootRefs: ["root"],
            nodes: [
                "root": node(ref: "root", parent: nil, frame: LoupeRect(x: 0, y: 0, width: 200, height: 200), children: ["target"]),
                "target": node(ref: "target", parent: "root", frame: LoupeRect(x: 20, y: 40, width: 80, height: 40)),
            ]
        )

        let stack = try LoupePaintStackBuilder.stack(in: snapshot, centeredOn: "target")

        #expect(stack.sourceRef == "target")
        #expect(stack.point == LoupePoint(x: 60, y: 60))
        #expect(stack.entries.first?.ref == "target")
    }

    private func node(
        ref: String,
        parent: String?,
        frame: LoupeRect,
        text: String? = nil,
        children: [String] = []
    ) -> LoupeNode {
        LoupeNode(
            ref: ref,
            parentRef: parent,
            kind: .view,
            typeName: "UIView",
            text: text,
            frame: frame,
            isVisible: true,
            isEnabled: true,
            isInteractive: false,
            children: children
        )
    }
}

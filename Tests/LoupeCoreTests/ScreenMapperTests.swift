import Foundation
import Testing
@testable import LoupeCore

struct ScreenMapperTests {
    @Test func screenMapKeepsSemanticAndStyledVisibleElements() {
        let snapshot = LoupeSnapshot(
            id: "s1",
            capturedAt: Date(timeIntervalSince1970: 0),
            screen: LoupeScreen(size: LoupeSize(width: 390, height: 844), scale: 3),
            rootRefs: ["n1"],
            nodes: [
                "n1": LoupeNode(
                    ref: "n1",
                    parentRef: nil,
                    kind: .application,
                    typeName: "UIApplication",
                    frame: LoupeRect(x: 0, y: 0, width: 390, height: 844),
                    isVisible: true,
                    isEnabled: true,
                    isInteractive: false,
                    children: ["n2", "n3", "n4", "n5", "n6"]
                ),
                "n2": LoupeNode(
                    ref: "n2",
                    parentRef: "n1",
                    kind: .view,
                    typeName: "UIView",
                    frame: LoupeRect(x: 20, y: 20, width: 100, height: 100),
                    isVisible: true,
                    isEnabled: true,
                    isInteractive: false,
                    style: LoupeStyle(backgroundColor: LoupeColor(red: 1, green: 0, blue: 0, alpha: 1))
                ),
                "n3": LoupeNode(
                    ref: "n3",
                    parentRef: "n1",
                    kind: .view,
                    typeName: "UILabel",
                    role: "staticText",
                    text: "Reading Now",
                    frame: LoupeRect(x: 20, y: 140, width: 160, height: 32),
                    isVisible: true,
                    isEnabled: true,
                    isInteractive: false
                ),
                "n4": LoupeNode(
                    ref: "n4",
                    parentRef: "n1",
                    kind: .view,
                    typeName: "UIButton",
                    role: "button",
                    testID: "primary",
                    text: "Done",
                    frame: LoupeRect(x: 300, y: 40, width: 60, height: 36),
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
                ),
                "n5": LoupeNode(
                    ref: "n5",
                    parentRef: "n1",
                    kind: .view,
                    typeName: "UIView",
                    role: "window",
                    frame: LoupeRect(x: 20, y: 220, width: 100, height: 100),
                    isVisible: true,
                    isEnabled: true,
                    isInteractive: false,
                    style: LoupeStyle(cornerRadius: 0, borderWidth: 0)
                ),
                "n6": LoupeNode(
                    ref: "n6",
                    parentRef: "n1",
                    kind: .view,
                    typeName: "UILabel",
                    text: "Offscreen",
                    frame: LoupeRect(x: 20, y: 900, width: 160, height: 32),
                    isVisible: true,
                    isEnabled: true,
                    isInteractive: false
                ),
            ]
        )

        let map = LoupeScreenMapper.map(snapshot)

        #expect(map.snapshotID == "s1")
        #expect(map.elements.map { $0.ref } == ["n2", "n4", "n3"])
        #expect(map.elements.map { $0.depth } == [1, 1, 1])
        #expect(map.elements[0].style?.backgroundColor == LoupeColor(red: 1, green: 0, blue: 0, alpha: 1))
        #expect(map.elements[1].text == "Done")
        #expect(map.elements[1].className == "UIButton")
        #expect(map.elements[1].isInteractive)
    }

    @Test func screenMapCanIncludePlainContainers() {
        let snapshot = LoupeSnapshot(
            id: "s2",
            capturedAt: Date(timeIntervalSince1970: 0),
            screen: LoupeScreen(size: LoupeSize(width: 100, height: 100), scale: 2),
            rootRefs: ["n1"],
            nodes: [
                "n1": LoupeNode(
                    ref: "n1",
                    parentRef: nil,
                    kind: .window,
                    typeName: "UIWindow",
                    frame: LoupeRect(x: 0, y: 0, width: 100, height: 100),
                    isVisible: true,
                    isEnabled: true,
                    isInteractive: false,
                    children: ["n2"]
                ),
                "n2": LoupeNode(
                    ref: "n2",
                    parentRef: "n1",
                    kind: .view,
                    typeName: "UIView",
                    frame: LoupeRect(x: 0, y: 0, width: 100, height: 100),
                    isVisible: true,
                    isEnabled: true,
                    isInteractive: false
                ),
            ]
        )

        #expect(LoupeScreenMapper.map(snapshot).elements.isEmpty)
        #expect(
            LoupeScreenMapper.map(
                snapshot,
                options: LoupeScreenMapOptions(includeContainers: true)
            ).elements.map(\.ref) == ["n1", "n2"]
        )
    }
}

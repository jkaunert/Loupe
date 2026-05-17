import XCTest
@testable import LoupeCore

final class ObservationCompactorTests: XCTestCase {
    func testCompactObservationKeepsVisibleTextAndInteractiveElements() {
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
                    children: ["n2", "n3", "n4"]
                ),
                "n2": LoupeNode(
                    ref: "n2",
                    parentRef: "n1",
                    kind: .view,
                    typeName: "UILabel",
                    role: "staticText",
                    text: "Checkout",
                    frame: LoupeRect(x: 24, y: 80, width: 120, height: 32),
                    isVisible: true,
                    isEnabled: true,
                    isInteractive: false
                ),
                "n3": LoupeNode(
                    ref: "n3",
                    parentRef: "n1",
                    kind: .view,
                    typeName: "UIButton",
                    role: "button",
                    testID: "checkout.payButton",
                    text: "Pay now",
                    frame: LoupeRect(x: 24, y: 760, width: 342, height: 52),
                    isVisible: true,
                    isEnabled: true,
                    isInteractive: true
                ),
                "n4": LoupeNode(
                    ref: "n4",
                    parentRef: "n1",
                    kind: .view,
                    typeName: "UILabel",
                    role: "staticText",
                    text: "Offscreen",
                    frame: LoupeRect(x: 24, y: 900, width: 120, height: 32),
                    isVisible: true,
                    isEnabled: true,
                    isInteractive: false
                ),
            ]
        )

        let observation = LoupeObservationCompactor.compact(snapshot)

        XCTAssertEqual(observation.snapshotID, "s1")
        XCTAssertEqual(observation.visibleTexts.map(\.text), ["Checkout", "Pay now"])
        XCTAssertEqual(observation.interactive.count, 1)
        XCTAssertEqual(observation.interactive[0].ref, "n3")
        XCTAssertEqual(observation.interactive[0].testID, "checkout.payButton")
    }
}

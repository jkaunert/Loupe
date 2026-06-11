import Foundation
import Testing
@testable import LoupeCore

struct RuntimeTests {
    @Test func snapshotNodeCanCarryUIKitAndAccessibilityProperties() {
        let node = LoupeNode(
            ref: "n1",
            parentRef: nil,
            kind: .view,
            typeName: "UIButton",
            role: "button",
            testID: "checkout.payButton",
            frame: LoupeRect(x: 10, y: 20, width: 100, height: 44),
            isVisible: true,
            isEnabled: true,
            isInteractive: true,
            style: LoupeStyle(
                tintColor: LoupeColor(red: 0, green: 0.478, blue: 1, alpha: 1),
                shadowOpacity: 0.2,
                shadowRadius: 8,
                shadowOffset: LoupeSize(width: 0, height: 2)
            ),
            accessibility: LoupeAccessibility(
                identifier: "checkout.payButton",
                label: "Pay",
                traits: ["button"],
                activationPoint: LoupePoint(x: 60, y: 42),
                isElement: true
            ),
            uikit: LoupeUIKitProperties(
                className: "UIButton",
                tag: 7,
                alpha: 1,
                isHidden: false,
                isOpaque: false,
                clipsToBounds: true,
                userInteractionEnabled: true,
                gestureRecognizers: [],
                isFirstResponder: false,
                control: LoupeUIControlProperties(
                    controlState: "normal",
                    controlEvents: ["touchUpInside"]
                ),
                label: LoupeUILabelProperties(
                    textAlignment: "center",
                    numberOfLines: 1
                )
            )
        )

        #expect(node.accessibility?.identifier == "checkout.payButton")
        #expect(node.accessibility?.traits == ["button"])
        #expect(node.platform?.className == "UIButton")
        #expect(node.platform?.control?.controlEvents == ["touchUpInside"])
        #expect(node.platform?.label?.textAlignment == "center")
        #expect(node.style?.tintColor?.blue == 1)
        #expect(node.style?.shadowRadius == 8)
        #expect(node.style?.shadowOffset == LoupeSize(width: 0, height: 2))
    }

    @Test func snapshotNodeCanCarryExtendedUIKitComponentProperties() {
        let date = Date(timeIntervalSince1970: 1_704_067_200)
        let node = LoupeNode(
            ref: "n2",
            parentRef: nil,
            kind: .view,
            typeName: "UIPickerView",
            role: "pickerView",
            testID: "components.picker",
            isVisible: true,
            isEnabled: true,
            isInteractive: true,
            uikit: LoupeUIKitProperties(
                className: "UIPickerView",
                tag: 0,
                alpha: 1,
                isHidden: false,
                isOpaque: false,
                clipsToBounds: false,
                userInteractionEnabled: true,
                isFirstResponder: false,
                scrollView: LoupeUIScrollViewProperties(
                    contentOffset: LoupePoint(x: 0, y: 240),
                    contentSize: LoupeSize(width: 350, height: 1_240),
                    contentInset: LoupeInsets(top: 12, left: 0, bottom: 20, right: 0),
                    adjustedContentInset: LoupeInsets(top: 12, left: 0, bottom: 34, right: 0),
                    scrollIndicatorInsets: LoupeInsets(top: 12, left: 0, bottom: 34, right: 0),
                    isScrollEnabled: true,
                    isPagingEnabled: false,
                    bounces: true,
                    alwaysBounceVertical: true,
                    alwaysBounceHorizontal: false,
                    showsVerticalScrollIndicator: true,
                    showsHorizontalScrollIndicator: false
                ),
                stepper: LoupeUIStepperProperties(value: 4, stepValue: 2),
                datePicker: LoupeUIDatePickerProperties(mode: "date", date: date),
                pageControl: LoupeUIPageControlProperties(currentPage: 2, numberOfPages: 5),
                progressView: LoupeUIProgressViewProperties(value: 0.65),
                activityIndicator: LoupeUIActivityIndicatorProperties(isAnimating: true, style: "medium"),
                imageView: LoupeUIImageViewProperties(imageSize: LoupeSize(width: 20, height: 20)),
                pickerView: LoupeUIPickerViewProperties(numberOfComponents: 1, selectedRows: [1]),
                tabBar: LoupeUITabBarProperties(items: ["Home", "Search"], selectedItem: "Home"),
                webView: LoupeWKWebViewProperties(
                    url: "https://loupe.local/fixture",
                    title: "Web Fixture"
                )
            )
        )

        #expect(node.platform?.stepper?.value == 4)
        #expect(node.platform?.stepper?.stepValue == 2)
        #expect(node.platform?.datePicker?.mode == "date")
        #expect(node.platform?.datePicker?.date == date)
        #expect(node.platform?.pageControl?.currentPage == 2)
        #expect(node.platform?.pageControl?.numberOfPages == 5)
        #expect(node.platform?.progressView?.value == 0.65)
        #expect(node.platform?.activityIndicator?.isAnimating == true)
        #expect(node.platform?.activityIndicator?.style == "medium")
        #expect(node.platform?.imageView?.imageSize == LoupeSize(width: 20, height: 20))
        #expect(node.platform?.pickerView?.numberOfComponents == 1)
        #expect(node.platform?.pickerView?.selectedRows == [1])
        #expect(node.platform?.tabBar?.items == ["Home", "Search"])
        #expect(node.platform?.tabBar?.selectedItem == "Home")
        #expect(node.platform?.scrollView?.contentInset.bottom == 20)
        #expect(node.platform?.scrollView?.scrollIndicatorInsets.bottom == 34)
        #expect(node.platform?.scrollView?.showsHorizontalScrollIndicator == false)
        #expect(node.platform?.webView?.url == "https://loupe.local/fixture")
        #expect(node.platform?.webView?.title == "Web Fixture")
    }

    @Test func scrollViewPropertiesDecodeOlderSnapshots() throws {
        let data = Data(
            """
            {
              "contentOffset": { "x": 0, "y": 120 },
              "contentSize": { "width": 390, "height": 1200 },
              "adjustedContentInset": { "top": 0, "left": 0, "bottom": 34, "right": 0 },
              "isScrollEnabled": true,
              "alwaysBounceVertical": true,
              "alwaysBounceHorizontal": false
            }
            """.utf8
        )

        let scrollView = try JSONDecoder().decode(LoupeUIScrollViewProperties.self, from: data)

        #expect(scrollView.contentInset == LoupeInsets(top: 0, left: 0, bottom: 0, right: 0))
        #expect(scrollView.scrollIndicatorInsets == LoupeInsets(top: 0, left: 0, bottom: 0, right: 0))
        #expect(scrollView.isPagingEnabled == false)
        #expect(scrollView.bounces == true)
        #expect(scrollView.showsVerticalScrollIndicator == true)
        #expect(scrollView.showsHorizontalScrollIndicator == true)
    }

    @Test func nodeKindDecodesLegacySyntheticTabBarItemSnapshotsAsViews() throws {
        let data = Data(
            """
            {
              "ref": "n403",
              "kind": "tabBarItem",
              "typeName": "UITabBarItem",
              "role": "button",
              "text": "Settings",
              "isVisible": true,
              "isEnabled": true,
              "isInteractive": true
            }
            """.utf8
        )

        let node = try JSONDecoder().decode(LoupeNode.self, from: data)

        #expect(node.kind == .view)
        #expect(node.typeName == "UITabBarItem")
        #expect(node.role == "button")
        #expect(node.custom.isEmpty)
        #expect(node.children.isEmpty)
    }

    @Test func snapshotNodeCanCarryLayoutAndStackViewProperties() {
        let node = LoupeNode(
            ref: "stack",
            parentRef: nil,
            kind: .view,
            typeName: "UIStackView",
            testID: "place.actions",
            isVisible: true,
            isEnabled: true,
            isInteractive: false,
            uikit: LoupeUIKitProperties(
                className: "UIStackView",
                tag: 0,
                alpha: 1,
                isHidden: false,
                isOpaque: false,
                clipsToBounds: false,
                userInteractionEnabled: true,
                isFirstResponder: false,
                layout: LoupeUILayoutProperties(
                    translatesAutoresizingMaskIntoConstraints: false,
                    isAmbiguousLayout: true,
                    hugging: LoupeUILayoutPriorities(horizontal: 250, vertical: 251),
                    compressionResistance: LoupeUILayoutPriorities(horizontal: 750, vertical: 751),
                    constraints: [
                        LoupeUILayoutConstraintProperties(
                            id: "c-height",
                            identifier: "height",
                            firstItem: "UIStackView#place.actions",
                            firstAttribute: "height",
                            relation: "equal",
                            secondItem: nil,
                            secondAttribute: "notAnAttribute",
                            multiplier: 1,
                            constant: 52,
                            priority: 1000,
                            isActive: true
                        )
                    ]
                ),
                stackView: LoupeUIStackViewProperties(
                    axis: "horizontal",
                    alignment: "fill",
                    distribution: "fillEqually",
                    spacing: 8,
                    isBaselineRelativeArrangement: false,
                    isLayoutMarginsRelativeArrangement: true,
                    arrangedSubviewCount: 3
                )
            )
        )

        #expect(node.platform?.layout?.translatesAutoresizingMaskIntoConstraints == false)
        #expect(node.platform?.layout?.isAmbiguousLayout == true)
        #expect(node.platform?.layout?.hugging.horizontal == 250)
        #expect(node.platform?.layout?.compressionResistance.vertical == 751)
        #expect(node.platform?.layout?.constraints.first?.id == "c-height")
        #expect(node.platform?.layout?.constraints.first?.identifier == "height")
        #expect(node.platform?.stackView?.axis == "horizontal")
        #expect(node.platform?.stackView?.distribution == "fillEqually")
        #expect(node.platform?.stackView?.arrangedSubviewCount == 3)
    }

    @Test func layoutPropertiesDecodeOlderSnapshots() throws {
        let data = Data(
            """
            {
              "translatesAutoresizingMaskIntoConstraints": false,
              "hugging": { "horizontal": 250, "vertical": 251 },
              "compressionResistance": { "horizontal": 750, "vertical": 751 }
            }
            """.utf8
        )

        let layout = try JSONDecoder().decode(LoupeUILayoutProperties.self, from: data)

        #expect(layout.translatesAutoresizingMaskIntoConstraints == false)
        #expect(layout.isAmbiguousLayout == false)
        #expect(layout.hugging.vertical == 251)
        #expect(layout.compressionResistance.horizontal == 750)
        #expect(layout.constraints.isEmpty)
        #expect(layout.affectingHorizontalConstraints.isEmpty)
        #expect(layout.affectingVerticalConstraints.isEmpty)
    }
}

import LoupeCore
import Testing
@testable import LoupeCLI

struct CaptureReportTests {
    @Test func scrollViewSummaryReportsScrollableAxes() {
        let node = LoupeNode(
            ref: "scroll",
            parentRef: nil,
            kind: .view,
            typeName: "UIScrollView",
            testID: "feed.scroll",
            frame: LoupeRect(x: 0, y: 0, width: 320, height: 500),
            isVisible: true,
            isEnabled: true,
            isInteractive: true
        )
        let scrollView = LoupeUIScrollViewProperties(
            contentOffset: LoupePoint(x: 0, y: 100),
            contentSize: LoupeSize(width: 640, height: 1_200),
            contentInset: LoupeInsets(top: 0, left: 0, bottom: 0, right: 0),
            adjustedContentInset: LoupeInsets(top: 0, left: 0, bottom: 0, right: 0),
            scrollIndicatorInsets: LoupeInsets(top: 0, left: 0, bottom: 0, right: 0),
            isScrollEnabled: true,
            isPagingEnabled: false,
            bounces: true,
            alwaysBounceVertical: true,
            alwaysBounceHorizontal: true,
            showsVerticalScrollIndicator: true,
            showsHorizontalScrollIndicator: true
        )

        let summary = CaptureReportScrollView(node: node, scrollView: scrollView)

        #expect(summary.ref == "scroll")
        #expect(summary.testID == "feed.scroll")
        #expect(summary.scrollableAxes == ["horizontal", "vertical"])
    }

    @Test func disabledScrollViewReportsNoScrollableAxes() {
        let node = LoupeNode(
            ref: "scroll",
            parentRef: nil,
            kind: .view,
            typeName: "UIScrollView",
            frame: LoupeRect(x: 0, y: 0, width: 320, height: 500),
            isVisible: true,
            isEnabled: true,
            isInteractive: true
        )
        let scrollView = LoupeUIScrollViewProperties(
            contentOffset: LoupePoint(x: 0, y: 0),
            contentSize: LoupeSize(width: 320, height: 1_200),
            contentInset: LoupeInsets(top: 0, left: 0, bottom: 0, right: 0),
            adjustedContentInset: LoupeInsets(top: 0, left: 0, bottom: 0, right: 0),
            scrollIndicatorInsets: LoupeInsets(top: 0, left: 0, bottom: 0, right: 0),
            isScrollEnabled: false,
            isPagingEnabled: false,
            bounces: true,
            alwaysBounceVertical: true,
            alwaysBounceHorizontal: false,
            showsVerticalScrollIndicator: true,
            showsHorizontalScrollIndicator: false
        )

        let summary = CaptureReportScrollView(node: node, scrollView: scrollView)

        #expect(summary.scrollableAxes.isEmpty)
    }
}

import Foundation
import LoupeCore

#if canImport(UIKit)
import ObjectiveC
import UIKit

private nonisolated(unsafe) var loupeMetadataKey: UInt8 = 0

public extension UIView {
    var loupeMetadata: [String: LoupeMetadataValue] {
        get {
            objc_getAssociatedObject(self, &loupeMetadataKey) as? [String: LoupeMetadataValue] ?? [:]
        }
        set {
            objc_setAssociatedObject(
                self,
                &loupeMetadataKey,
                newValue,
                .OBJC_ASSOCIATION_RETAIN_NONATOMIC
            )
        }
    }

    func testID(_ id: String) {
        accessibilityIdentifier = id
        loupeMetadata["id"] = .string(id)
    }

    func testProperty(_ key: String, _ value: String) {
        loupeMetadata[key] = .string(value)
    }

    func testProperty(_ key: String, _ value: Bool) {
        loupeMetadata[key] = .bool(value)
    }

    func testProperty(_ key: String, _ value: Int) {
        loupeMetadata[key] = .int(value)
    }

    func testProperty(_ key: String, _ value: Double) {
        loupeMetadata[key] = .double(value)
    }
}

@MainActor
public final class LoupeAgent {
    private var nextRef = 0

    public init() {}

    public func captureSnapshot() -> LoupeSnapshot {
        nextRef = 0

        var nodes: [String: LoupeNode] = [:]
        let screen = UIScreen.main
        let screenBounds = screen.bounds
        let interfaceStyle = UIApplication.shared.connectedScenes
            .compactMap { ($0 as? UIWindowScene)?.keyWindow?.traitCollection.userInterfaceStyle }
            .first
            .map(interfaceStyleName)

        let screenInfo = LoupeScreen(
            size: LoupeSize(
                width: finiteDouble(screenBounds.width.doubleValue) ?? 0,
                height: finiteDouble(screenBounds.height.doubleValue) ?? 0
            ),
            scale: finiteDouble(screen.scale.doubleValue) ?? 1,
            interfaceStyle: interfaceStyle
        )

        let appRef = makeRef()
        var sceneRefs: [String] = []

        for scene in UIApplication.shared.connectedScenes.compactMap({ $0 as? UIWindowScene }) {
            let sceneRef = makeRef()
            var windowRefs: [String] = []

            for window in scene.windows {
                let windowRef = captureWindow(window, parentRef: sceneRef, nodes: &nodes)
                windowRefs.append(windowRef)
            }

            nodes[sceneRef] = LoupeNode(
                ref: sceneRef,
                parentRef: appRef,
                kind: .scene,
                typeName: "UIWindowScene",
                role: "scene",
                frame: nil,
                isVisible: scene.activationState == .foregroundActive,
                isEnabled: true,
                isInteractive: false,
                custom: [
                    "activationState": .string(sceneActivationStateName(scene.activationState))
                ],
                children: windowRefs
            )
            sceneRefs.append(sceneRef)
        }

        nodes[appRef] = LoupeNode(
            ref: appRef,
            parentRef: nil,
            kind: .application,
            typeName: "UIApplication",
            role: "application",
            frame: LoupeRect(
                x: 0,
                y: 0,
                width: finiteDouble(screenBounds.width.doubleValue) ?? 0,
                height: finiteDouble(screenBounds.height.doubleValue) ?? 0
            ),
            isVisible: true,
            isEnabled: true,
            isInteractive: false,
            children: sceneRefs
        )

        return LoupeSnapshot(
            id: UUID().uuidString,
            capturedAt: Date(),
            screen: screenInfo,
            rootRefs: [appRef],
            nodes: nodes
        )
    }

    public func captureCompactObservation(
        options: LoupeObservationOptions = LoupeObservationOptions()
    ) -> LoupeCompactObservation {
        LoupeObservationCompactor.compact(captureSnapshot(), options: options)
    }

    public func encodedSnapshot() throws -> Data {
        try encodedSnapshot(encoder: makeLoupeJSONEncoder())
    }

    public func encodedSnapshot(encoder: JSONEncoder) throws -> Data {
        try encoder.encode(captureSnapshot())
    }

    private func captureWindow(
        _ window: UIWindow,
        parentRef: String,
        nodes: inout [String: LoupeNode]
    ) -> String {
        let ref = makeRef()
        var childRefs: [String] = []

        for subview in window.subviews {
            let childRef = captureView(
                subview,
                parentRef: ref,
                inheritedVisible: window.isHidden == false && window.alpha > 0.01,
                nodes: &nodes
            )
            childRefs.append(childRef)
        }

        nodes[ref] = LoupeNode(
            ref: ref,
            parentRef: parentRef,
            kind: .window,
            typeName: typeName(of: window),
            role: "window",
            frame: loupeRect(from: window.frame),
            isVisible: window.isHidden == false && window.alpha > 0.01,
            isEnabled: true,
            isInteractive: true,
            style: style(for: window),
            custom: window.loupeMetadata,
            children: childRefs
        )

        return ref
    }

    private func captureView(
        _ view: UIView,
        parentRef: String,
        inheritedVisible: Bool,
        nodes: inout [String: LoupeNode]
    ) -> String {
        let ref = makeRef()
        let visible = inheritedVisible
            && view.isHidden == false
            && view.alpha > 0.01
            && view.bounds.width > 0
            && view.bounds.height > 0

        var childRefs: [String] = []
        for subview in view.subviews {
            let childRef = captureView(
                subview,
                parentRef: ref,
                inheritedVisible: visible,
                nodes: &nodes
            )
            childRefs.append(childRef)
        }

        nodes[ref] = LoupeNode(
            ref: ref,
            parentRef: parentRef,
            kind: .view,
            typeName: typeName(of: view),
            role: role(for: view),
            testID: view.accessibilityIdentifier ?? stringMetadata("id", from: view.loupeMetadata),
            label: view.accessibilityLabel,
            value: view.accessibilityValue,
            placeholder: placeholder(for: view),
            text: text(for: view),
            frame: frameInScreen(for: view),
            isVisible: visible,
            isEnabled: isEnabled(view),
            isInteractive: isInteractive(view),
            style: style(for: view),
            custom: view.loupeMetadata,
            children: childRefs
        )

        return ref
    }

    private func makeRef() -> String {
        nextRef += 1
        return "n\(nextRef)"
    }
}

func makeLoupeJSONEncoder() -> JSONEncoder {
    let encoder = JSONEncoder()
    encoder.dateEncodingStrategy = .iso8601
    encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
    return encoder
}

@MainActor
private func frameInScreen(for view: UIView) -> LoupeRect? {
    guard view.window != nil else { return nil }
    return loupeRect(from: view.convert(view.bounds, to: nil))
}

private func loupeRect(from rect: CGRect) -> LoupeRect {
    LoupeRect(
        x: finiteDouble(rect.origin.x.doubleValue) ?? 0,
        y: finiteDouble(rect.origin.y.doubleValue) ?? 0,
        width: finiteDouble(rect.size.width.doubleValue) ?? 0,
        height: finiteDouble(rect.size.height.doubleValue) ?? 0
    )
}

@MainActor
private func role(for view: UIView) -> String? {
    if view is UIButton { return "button" }
    if view is UITextField { return "textField" }
    if view is UITextView { return "textView" }
    if view is UISwitch { return "switch" }
    if view is UISlider { return "slider" }
    if view is UISegmentedControl { return "segmentedControl" }
    if view is UITableViewCell || view is UICollectionViewCell { return "cell" }
    if view is UIImageView { return "image" }
    if view is UILabel { return "staticText" }
    if view is UIScrollView { return "scrollView" }

    if view.accessibilityTraits.contains(.button) { return "button" }
    if view.accessibilityTraits.contains(.link) { return "link" }
    if view.accessibilityTraits.contains(.image) { return "image" }
    if view.accessibilityTraits.contains(.staticText) { return "staticText" }
    if view.accessibilityTraits.contains(.searchField) { return "searchField" }

    return nil
}

@MainActor
private func text(for view: UIView) -> String? {
    if let label = view as? UILabel {
        return label.text
    }

    if let button = view as? UIButton {
        return button.title(for: button.state) ?? button.currentTitle
    }

    if let textField = view as? UITextField {
        return textField.text
    }

    if let textView = view as? UITextView {
        return textView.text
    }

    if let segmentedControl = view as? UISegmentedControl {
        return (0..<segmentedControl.numberOfSegments)
            .compactMap { segmentedControl.titleForSegment(at: $0) }
            .joined(separator: " ")
    }

    return nil
}

@MainActor
private func placeholder(for view: UIView) -> String? {
    (view as? UITextField)?.placeholder
}

@MainActor
private func isEnabled(_ view: UIView) -> Bool {
    if let control = view as? UIControl {
        return control.isEnabled
    }
    return true
}

@MainActor
private func isInteractive(_ view: UIView) -> Bool {
    if view is UIControl { return true }
    if let recognizers = view.gestureRecognizers, !recognizers.isEmpty {
        return true
    }
    if view.accessibilityTraits.contains(.button)
        || view.accessibilityTraits.contains(.link)
        || view.accessibilityTraits.contains(.adjustable)
        || view.accessibilityTraits.contains(.keyboardKey) {
        return true
    }
    return false
}

@MainActor
private func style(for view: UIView) -> LoupeStyle {
    LoupeStyle(
        alpha: finiteDouble(view.alpha.doubleValue),
        backgroundColor: loupeColor(from: view.backgroundColor, traitCollection: view.traitCollection),
        cornerRadius: finiteDouble(view.layer.cornerRadius.doubleValue),
        fontName: font(for: view)?.fontName,
        fontSize: font(for: view).flatMap { finiteDouble($0.pointSize.doubleValue) },
        textColor: loupeColor(from: textColor(for: view), traitCollection: view.traitCollection)
    )
}

@MainActor
private func font(for view: UIView) -> UIFont? {
    if let label = view as? UILabel {
        return label.font
    }
    if let button = view as? UIButton {
        return button.titleLabel?.font
    }
    if let textField = view as? UITextField {
        return textField.font
    }
    if let textView = view as? UITextView {
        return textView.font
    }
    return nil
}

@MainActor
private func textColor(for view: UIView) -> UIColor? {
    if let label = view as? UILabel {
        return label.textColor
    }
    if let button = view as? UIButton {
        return button.titleColor(for: button.state) ?? button.currentTitleColor
    }
    if let textField = view as? UITextField {
        return textField.textColor
    }
    if let textView = view as? UITextView {
        return textView.textColor
    }
    return nil
}

@MainActor
private func loupeColor(from color: UIColor?, traitCollection: UITraitCollection) -> LoupeColor? {
    guard let color else { return nil }

    let resolved = color.resolvedColor(with: traitCollection)
    var red: CGFloat = 0
    var green: CGFloat = 0
    var blue: CGFloat = 0
    var alpha: CGFloat = 0

    guard resolved.getRed(&red, green: &green, blue: &blue, alpha: &alpha) else {
        return nil
    }

    return LoupeColor(
        red: finiteDouble(red.doubleValue) ?? 0,
        green: finiteDouble(green.doubleValue) ?? 0,
        blue: finiteDouble(blue.doubleValue) ?? 0,
        alpha: finiteDouble(alpha.doubleValue) ?? 0
    )
}

private func finiteDouble(_ value: Double) -> Double? {
    value.isFinite ? value : nil
}

private func stringMetadata(
    _ key: String,
    from metadata: [String: LoupeMetadataValue]
) -> String? {
    guard case let .string(value) = metadata[key] else {
        return nil
    }
    return value
}

private func typeName(of value: AnyObject) -> String {
    String(describing: type(of: value))
}

private func interfaceStyleName(_ style: UIUserInterfaceStyle) -> String {
    switch style {
    case .dark:
        return "dark"
    case .light:
        return "light"
    case .unspecified:
        return "unspecified"
    @unknown default:
        return "unknown"
    }
}

private func sceneActivationStateName(_ state: UIScene.ActivationState) -> String {
    switch state {
    case .foregroundActive:
        return "foregroundActive"
    case .foregroundInactive:
        return "foregroundInactive"
    case .background:
        return "background"
    case .unattached:
        return "unattached"
    @unknown default:
        return "unknown"
    }
}

private extension CGFloat {
    var doubleValue: Double { Double(self) }
}

#endif

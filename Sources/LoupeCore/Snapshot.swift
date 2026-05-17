import Foundation

public enum LoupeNodeKind: String, Codable, Equatable {
    case application
    case scene
    case window
    case view
}

public struct LoupeStyle: Codable, Equatable {
    public var alpha: Double?
    public var backgroundColor: LoupeColor?
    public var cornerRadius: Double?
    public var fontName: String?
    public var fontSize: Double?
    public var textColor: LoupeColor?

    public init(
        alpha: Double? = nil,
        backgroundColor: LoupeColor? = nil,
        cornerRadius: Double? = nil,
        fontName: String? = nil,
        fontSize: Double? = nil,
        textColor: LoupeColor? = nil
    ) {
        self.alpha = alpha
        self.backgroundColor = backgroundColor
        self.cornerRadius = cornerRadius
        self.fontName = fontName
        self.fontSize = fontSize
        self.textColor = textColor
    }
}

public struct LoupeNode: Codable, Equatable {
    public var ref: String
    public var parentRef: String?
    public var kind: LoupeNodeKind
    public var typeName: String
    public var role: String?
    public var testID: String?
    public var label: String?
    public var value: String?
    public var placeholder: String?
    public var text: String?
    public var frame: LoupeRect?
    public var isVisible: Bool
    public var isEnabled: Bool
    public var isInteractive: Bool
    public var style: LoupeStyle?
    public var custom: [String: LoupeMetadataValue]
    public var children: [String]

    public init(
        ref: String,
        parentRef: String?,
        kind: LoupeNodeKind,
        typeName: String,
        role: String? = nil,
        testID: String? = nil,
        label: String? = nil,
        value: String? = nil,
        placeholder: String? = nil,
        text: String? = nil,
        frame: LoupeRect? = nil,
        isVisible: Bool,
        isEnabled: Bool,
        isInteractive: Bool,
        style: LoupeStyle? = nil,
        custom: [String: LoupeMetadataValue] = [:],
        children: [String] = []
    ) {
        self.ref = ref
        self.parentRef = parentRef
        self.kind = kind
        self.typeName = typeName
        self.role = role
        self.testID = testID
        self.label = label
        self.value = value
        self.placeholder = placeholder
        self.text = text
        self.frame = frame
        self.isVisible = isVisible
        self.isEnabled = isEnabled
        self.isInteractive = isInteractive
        self.style = style
        self.custom = custom
        self.children = children
    }
}

public struct LoupeScreen: Codable, Equatable {
    public var size: LoupeSize
    public var scale: Double
    public var interfaceStyle: String?

    public init(size: LoupeSize, scale: Double, interfaceStyle: String? = nil) {
        self.size = size
        self.scale = scale
        self.interfaceStyle = interfaceStyle
    }
}

public struct LoupeSnapshot: Codable, Equatable {
    public var id: String
    public var capturedAt: Date
    public var screen: LoupeScreen
    public var rootRefs: [String]
    public var nodes: [String: LoupeNode]

    public init(
        id: String,
        capturedAt: Date,
        screen: LoupeScreen,
        rootRefs: [String],
        nodes: [String: LoupeNode]
    ) {
        self.id = id
        self.capturedAt = capturedAt
        self.screen = screen
        self.rootRefs = rootRefs
        self.nodes = nodes
    }
}

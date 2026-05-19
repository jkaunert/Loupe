import Foundation
import LoupeCLIModel
import LoupeCore

enum SkillInstallTargetSelection: String {
    case all
    case codex
    case claude

    var targets: [SkillInstallTarget] {
        switch self {
        case .all:
            return [.codex, .claude]
        case .codex:
            return [.codex]
        case .claude:
            return [.claude]
        }
    }
}

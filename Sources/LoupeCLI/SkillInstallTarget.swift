import Foundation
import LoupeCLIModel
import LoupeCore

struct SkillInstallTarget {
    var name: String
    var root: URL

    static let codex = SkillInstallTarget(
        name: "codex",
        root: FileManager.default.homeDirectoryForCurrentUser.appendingPathComponent(".codex", isDirectory: true)
    )

    static let claude = SkillInstallTarget(
        name: "claude",
        root: FileManager.default.homeDirectoryForCurrentUser.appendingPathComponent(".claude", isDirectory: true)
    )
}

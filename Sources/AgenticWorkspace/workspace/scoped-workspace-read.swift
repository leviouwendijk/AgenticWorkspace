import Path
import Readers

public struct ScopedWorkspaceRead: Sendable, Codable, Equatable {
    public let path: ScopedPath
    public let text: String
    public let encodingUsed: TextEncoding?
    public let byteCount: Int
    public let existed: Bool

    public init(
        path: ScopedPath,
        text: String,
        encodingUsed: TextEncoding?,
        byteCount: Int,
        existed: Bool
    ) {
        self.path = path
        self.text = text
        self.encodingUsed = encodingUsed
        self.byteCount = byteCount
        self.existed = existed
    }

    public var relativePath: String {
        path.presentingRelative(
            filetype: true
        )
    }

    public var isEmpty: Bool {
        text.isEmpty
    }
}

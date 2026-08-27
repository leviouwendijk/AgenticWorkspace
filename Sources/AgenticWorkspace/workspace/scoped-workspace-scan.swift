import Path

public struct ScopedWorkspaceScan: Sendable, Codable, Equatable {
    public struct Entry: Sendable, Codable, Equatable {
        public let path: ScopedPath
        public let isDirectory: Bool

        public init(
            path: ScopedPath,
            isDirectory: Bool
        ) {
            self.path = path
            self.isDirectory = isDirectory
        }

        public var relativePath: String {
            path.presentingRelative(
                filetype: true
            )
        }
    }

    public let directory: ScopedPath?
    public let entries: [Entry]

    public init(
        directory: ScopedPath? = nil,
        entries: [Entry] = []
    ) {
        self.directory = directory
        self.entries = entries
    }
}

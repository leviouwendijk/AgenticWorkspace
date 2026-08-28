import Path

public struct ScopedWorkspaceScan: Sendable, Codable, Equatable {
    public struct Entry: Sendable, Codable, Equatable {
        public let path: DescendantPath
        public let isDirectory: Bool

        public init(
            path: DescendantPath,
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

    public let directory: DescendantPath?
    public let entries: [Entry]

    public init(
        directory: DescendantPath? = nil,
        entries: [Entry] = []
    ) {
        self.directory = directory
        self.entries = entries
    }
}

public enum PathGrantMode: String, Sendable, Codable, Hashable, CaseIterable {
    case path_only
    case read_only
    case read_write
}

public extension PathGrantMode {
    var defaultCapabilities: Set<PathCapability> {
        switch self {
        case .path_only:
            return [
                .list,
                .scan
            ]

        case .read_only:
            return [
                .list,
                .scan,
                .read
            ]

        case .read_write:
            return [
                .list,
                .scan,
                .read,
                .write,
                .edit,
                .create_directory
            ]
        }
    }
}

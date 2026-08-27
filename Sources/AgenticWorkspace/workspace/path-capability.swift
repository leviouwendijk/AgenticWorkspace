public enum PathCapability: String, Sendable, Codable, Hashable, CaseIterable {
    case list
    case read
    case write
    case edit
    case scan
    case create_directory
}

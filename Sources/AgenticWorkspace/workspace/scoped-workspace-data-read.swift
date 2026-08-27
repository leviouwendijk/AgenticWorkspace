import Foundation
import Path

public struct ScopedWorkspaceDataRead: Sendable, Codable, Equatable {
    public let path: ScopedPath
    public let data: Data
    public let byteCount: Int
    public let existed: Bool

    public init(
        path: ScopedPath,
        data: Data,
        byteCount: Int,
        existed: Bool
    ) {
        self.path = path
        self.data = data
        self.byteCount = byteCount
        self.existed = existed
    }

    public var relativePath: String {
        path.presentingRelative(
            filetype: true
        )
    }

    public var isEmpty: Bool {
        data.isEmpty
    }
}

public struct ScopedWorkspaceBase64Read: Sendable, Codable, Equatable {
    public let path: ScopedPath
    public let base64: String
    public let mediaType: String?
    public let byteCount: Int
    public let existed: Bool

    public init(
        path: ScopedPath,
        base64: String,
        mediaType: String?,
        byteCount: Int,
        existed: Bool
    ) {
        self.path = path
        self.base64 = base64
        self.mediaType = mediaType
        self.byteCount = byteCount
        self.existed = existed
    }

    public var relativePath: String {
        path.presentingRelative(
            filetype: true
        )
    }

    public var isEmpty: Bool {
        base64.isEmpty
    }
}

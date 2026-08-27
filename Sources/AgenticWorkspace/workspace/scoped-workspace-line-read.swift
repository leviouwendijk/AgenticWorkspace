import Path
import Position
import Readers

public struct ScopedWorkspaceLineRead: Sendable, Codable, Equatable {
    public let path: ScopedPath
    public let lines: [String]
    public let encodingUsed: TextEncoding?
    public let byteCount: Int
    public let existed: Bool

    public init(
        path: ScopedPath,
        lines: [String],
        encodingUsed: TextEncoding?,
        byteCount: Int,
        existed: Bool
    ) {
        self.path = path
        self.lines = lines
        self.encodingUsed = encodingUsed
        self.byteCount = byteCount
        self.existed = existed
    }

    public var relativePath: String {
        path.presentingRelative(
            filetype: true
        )
    }

    public var lineCount: Int {
        lines.count
    }

    public var text: String {
        guard !lines.isEmpty else {
            return ""
        }

        return lines.joined(separator: "\n")
    }

    public var lineRange: LineRange? {
        guard !lines.isEmpty else {
            return nil
        }

        return try? LineRange(
            start: 1,
            end: lines.count
        )
    }
}

public struct ScopedWorkspaceLineSliceRead: Sendable, Codable, Equatable {
    public let path: ScopedPath
    public let selectedLines: [String]
    public let selectedLineRange: LineRange?
    public let totalLineCount: Int
    public let truncated: Bool
    public let encodingUsed: TextEncoding?
    public let byteCount: Int
    public let existed: Bool

    public init(
        path: ScopedPath,
        selectedLines: [String],
        selectedLineRange: LineRange?,
        totalLineCount: Int,
        truncated: Bool,
        encodingUsed: TextEncoding?,
        byteCount: Int,
        existed: Bool
    ) {
        self.path = path
        self.selectedLines = selectedLines
        self.selectedLineRange = selectedLineRange
        self.totalLineCount = totalLineCount
        self.truncated = truncated
        self.encodingUsed = encodingUsed
        self.byteCount = byteCount
        self.existed = existed
    }

    public var relativePath: String {
        path.presentingRelative(
            filetype: true
        )
    }

    public var lineCount: Int {
        selectedLines.count
    }

    public var text: String {
        guard !selectedLines.isEmpty else {
            return ""
        }

        return selectedLines.joined(separator: "\n")
    }
}

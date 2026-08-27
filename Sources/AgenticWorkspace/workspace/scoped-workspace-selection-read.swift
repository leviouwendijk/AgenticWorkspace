import Path
import Position
import Readers
import Selection

public struct ScopedWorkspaceSelectionRead: Sendable, Codable, Equatable {
    public let path: ScopedPath
    public let slices: [FileLineSlice]
    public let totalLineCount: Int
    public let encodingUsed: TextEncoding?
    public let byteCount: Int
    public let existed: Bool

    public init(
        path: ScopedPath,
        slices: [FileLineSlice],
        totalLineCount: Int,
        encodingUsed: TextEncoding?,
        byteCount: Int,
        existed: Bool
    ) {
        self.path = path
        self.slices = slices
        self.totalLineCount = totalLineCount
        self.encodingUsed = encodingUsed
        self.byteCount = byteCount
        self.existed = existed
    }

    public init(
        path: ScopedPath,
        resolved: ResolvedFileSelection
    ) {
        self.init(
            path: path,
            slices: resolved.slices,
            totalLineCount: resolved.totalLineCount,
            encodingUsed: resolved.encodingUsed,
            byteCount: resolved.byteCount,
            existed: resolved.existed
        )
    }

    public var relativePath: String {
        path.presentingRelative(
            filetype: true
        )
    }

    public var isEmpty: Bool {
        slices.allSatisfy(\.isEmpty)
    }

    public var sliceCount: Int {
        slices.count
    }

    public var selectedLineCount: Int {
        slices.reduce(0) { partial, slice in
            partial + slice.lines.count
        }
    }

    public var selectedText: String {
        slices
            .flatMap(\.lines)
            .joined(separator: "\n")
    }

    public var selectedLineRanges: [LineRange] {
        slices.compactMap { slice in
            guard !slice.lines.isEmpty else {
                return nil
            }

            return try? LineRange(
                start: slice.startLine,
                end: slice.endLine
            )
        }
    }
}

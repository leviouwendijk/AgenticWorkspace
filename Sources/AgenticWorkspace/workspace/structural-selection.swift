import Path
import Position

public struct StructuralSelection: Sendable, Hashable {
    public enum Kind: String, Sendable, Hashable, CaseIterable {
        case lines
        case declaration
        case type
        case member
        case enclosingScope
        case imports
    }

    public let path: ScopedPath
    public let lineRange: LineRange
    public let kind: Kind
    public let symbolName: String?
    public let summary: String?

    public init(
        path: ScopedPath,
        lineRange: LineRange,
        kind: Kind,
        symbolName: String? = nil,
        summary: String? = nil
    ) {
        self.path = path
        self.lineRange = lineRange
        self.kind = kind
        self.symbolName = symbolName
        self.summary = summary
    }
}

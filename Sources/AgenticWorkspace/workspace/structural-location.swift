public struct StructuralLocation: Sendable, Hashable {
    public let line: Int
    public let column: Int?

    public init(
        line: Int,
        column: Int? = nil
    ) {
        self.line = line
        self.column = column
    }
}

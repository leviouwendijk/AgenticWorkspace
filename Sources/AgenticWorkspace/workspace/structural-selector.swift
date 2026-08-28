import Path

public protocol StructuralSelector: Sendable {
    func selections(
        in file: DescendantPath,
        query: StructuralQuery
    ) async throws -> [StructuralSelection]
}

public extension StructuralSelector {
    func selection(
        in file: DescendantPath,
        query: StructuralQuery
    ) async throws -> StructuralSelection? {
        try await selections(
            in: file,
            query: query
        ).first
    }
}

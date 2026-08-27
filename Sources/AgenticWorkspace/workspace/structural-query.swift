import Position

public enum StructuralQuery: Sendable, Hashable {
    case lines(LineRange)
    case declaration(named: String)
    case type(named: String)
    case member(named: String, parentType: String?)
    case enclosingScope(StructuralLocation)
    case imports
}

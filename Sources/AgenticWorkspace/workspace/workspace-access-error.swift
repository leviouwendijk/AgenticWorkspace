import Foundation
import Path

public enum WorkspaceAccessError: Error, Sendable, LocalizedError, Equatable {
    case rootNotFound(PathAccessRootIdentifier)
    case pathOutsideRoots(String)
    case grantDenied(
        rootID: PathAccessRootIdentifier,
        capability: PathCapability,
        toolName: String
    )

    public var errorDescription: String? {
        switch self {
        case .rootNotFound(let rootID):
            return "No workspace path root exists for identifier '\(rootID.rawValue)'."

        case .pathOutsideRoots(let path):
            return "No workspace path root contains path '\(path)'."

        case .grantDenied(let rootID, let capability, let toolName):
            return """
            Workspace grant denied for root '\(rootID.rawValue)', \
            capability '\(capability.rawValue)', tool '\(toolName)'.
            """
        }
    }
}

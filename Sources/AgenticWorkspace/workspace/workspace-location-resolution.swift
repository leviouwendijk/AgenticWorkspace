import Foundation
import Path

public extension AgentWorkspace {
    /// Resolve a path relative to an optional working location while preserving
    /// the original workspace authority and root policy.
    ///
    /// WorkspaceLocation behaves like a working directory. It does not create
    /// a new workspace root or grant additional path authority.
    func resolve(
        _ rawPath: String,
        relativeTo location: WorkspaceLocation?,
        rootID: PathAccessRootIdentifier = .project,
        type: PathSegmentType? = nil
    ) throws -> DescendantPath {
        guard let location else {
            return try resolve(
                rootID: rootID,
                rawPath: rawPath,
                type: type
            )
        }

        let baseURL = URL(
            fileURLWithPath: location.absoluteURL.path,
            isDirectory: true
        )
        let targetURL = URL(
            fileURLWithPath: rawPath,
            relativeTo: baseURL
        ).standardizedFileURL

        return try scope(
            rootID: rootID,
            targetURL,
            type: type
        )
    }
}

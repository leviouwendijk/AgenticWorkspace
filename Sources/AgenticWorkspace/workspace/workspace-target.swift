import Foundation
import Path

public struct WorkspaceTarget:
    Sendable,
    Codable,
    Hashable
{
    public let subpath: String

    public init(
        subpath: String
    ) {
        self.subpath = subpath
    }
}

public struct WorkspaceLocation:
    Sendable,
    Codable,
    Hashable
{
    public let path: DescendantPath
    public let absoluteURL: URL

    public init(
        path: DescendantPath,
        absoluteURL: URL
    ) {
        self.path = path
        self.absoluteURL = absoluteURL
    }
}

public enum WorkspaceTargetError:
    Error,
    Sendable,
    LocalizedError,
    Equatable
{
    case emptySubpath
    case missing(String)
    case notDirectory(String)

    public var errorDescription: String? {
        switch self {
        case .emptySubpath:
            return "Workspace target subpath must not be empty."

        case .missing(let subpath):
            return "Workspace target '\(subpath)' does not exist."

        case .notDirectory(let subpath):
            return "Workspace target '\(subpath)' is not a directory."
        }
    }
}

public extension AgentWorkspace {
    func location(
        for target: WorkspaceTarget
    ) throws -> WorkspaceLocation {
        let subpath = target.subpath.trimmingCharacters(
            in: .whitespacesAndNewlines
        )

        guard !subpath.isEmpty else {
            throw WorkspaceTargetError.emptySubpath
        }

        let path = try resolve(
            subpath,
            type: .directory
        )

        guard let existingType = try existingType(
            of: path
        ) else {
            throw WorkspaceTargetError.missing(
                subpath
            )
        }

        guard existingType == .directory else {
            throw WorkspaceTargetError.notDirectory(
                subpath
            )
        }

        return .init(
            path: path,
            absoluteURL: try absoluteURL(
                for: path,
                type: .directory
            )
        )
    }
}

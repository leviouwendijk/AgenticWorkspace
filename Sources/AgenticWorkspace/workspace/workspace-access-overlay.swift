import Foundation
import Path

public struct WorkspaceAccessOverlay:
    Sendable,
    Codable,
    Hashable
{
    public struct GrantedRoot:
        Sendable,
        Codable,
        Hashable
    {
        public let root: PathAccessRoot
        public let grant: PathGrant
        public let selection: WorkspaceSelection

        public init(
            root: PathAccessRoot,
            grant: PathGrant,
            selection: WorkspaceSelection = .all
        ) throws {
            guard root.id == grant.rootID else {
                throw WorkspaceAccessOverlayError.root_grant_mismatch(
                    root: root.id,
                    grant: grant.rootID
                )
            }

            self.root = root
            self.grant = grant
            self.selection = selection
        }

        private enum CodingKeys: String, CodingKey {
            case root
            case grant
            case selection
        }

        public init(
            from decoder: Decoder
        ) throws {
            let container = try decoder.container(
                keyedBy: CodingKeys.self
            )

            try self.init(
                root: container.decode(
                    PathAccessRoot.self,
                    forKey: .root
                ),
                grant: container.decode(
                    PathGrant.self,
                    forKey: .grant
                ),
                selection: container.decodeIfPresent(
                    WorkspaceSelection.self,
                    forKey: .selection
                ) ?? .all
            )
        }
    }

    public let roots: [GrantedRoot]
    public let grants: [PathGrant]

    public init(
        roots: [GrantedRoot] = [],
        grants: [PathGrant] = []
    ) throws {
        guard !roots.isEmpty || !grants.isEmpty else {
            throw WorkspaceAccessOverlayError.empty
        }

        if let rootID = Self.firstDuplicate(
            in: roots.map { root in
                root.root.id
            }
        ) {
            throw WorkspaceAccessOverlayError.duplicate_root(
                rootID
            )
        }

        let grantIDs = roots.map { root in
            root.grant.id
        } + grants.map(\.id)

        if let grantID = Self.firstDuplicate(
            in: grantIDs
        ) {
            throw WorkspaceAccessOverlayError.duplicate_grant(
                grantID
            )
        }

        self.roots = roots
        self.grants = grants
    }

    private enum CodingKeys: String, CodingKey {
        case roots
        case grants
    }

    public init(
        from decoder: Decoder
    ) throws {
        let container = try decoder.container(
            keyedBy: CodingKeys.self
        )

        try self.init(
            roots: container.decodeIfPresent(
                [GrantedRoot].self,
                forKey: .roots
            ) ?? [],
            grants: container.decodeIfPresent(
                [PathGrant].self,
                forKey: .grants
            ) ?? []
        )
    }
}

private extension WorkspaceAccessOverlay {
    static func firstDuplicate<Value: Hashable>(
        in values: [Value]
    ) -> Value? {
        var seen: Set<Value> = []

        for value in values {
            guard seen.insert(value).inserted else {
                return value
            }
        }

        return nil
    }
}

public enum WorkspaceAccessOverlayError:
    Error,
    Sendable,
    Hashable,
    LocalizedError
{
    case empty
    case root_grant_mismatch(
        root: PathAccessRootIdentifier,
        grant: PathAccessRootIdentifier
    )
    case duplicate_root(PathAccessRootIdentifier)
    case duplicate_grant(String)
    case root_already_present(PathAccessRootIdentifier)
    case grant_already_present(String)
    case grant_root_unavailable(PathAccessRootIdentifier)

    public var errorDescription: String? {
        switch self {
        case .empty:
            return "Workspace access overlay must contain at least one root or grant."

        case .root_grant_mismatch(let root, let grant):
            return "Workspace access overlay root '\(root.rawValue)' does not match grant root '\(grant.rawValue)'."

        case .duplicate_root(let rootID):
            return "Workspace access overlay contains duplicate root '\(rootID.rawValue)'."

        case .duplicate_grant(let grantID):
            return "Workspace access overlay contains duplicate grant '\(grantID)'."

        case .root_already_present(let rootID):
            return "Workspace access overlay cannot replace declared root '\(rootID.rawValue)'."

        case .grant_already_present(let grantID):
            return "Workspace access overlay cannot replace declared grant '\(grantID)'."

        case .grant_root_unavailable(let rootID):
            return "Workspace access overlay grant references unavailable root '\(rootID.rawValue)'."
        }
    }
}

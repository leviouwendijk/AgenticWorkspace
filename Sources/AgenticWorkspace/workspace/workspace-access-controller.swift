import Foundation
import FileTypes
import Path

public struct WorkspaceAccessController: Sendable, Codable, Hashable {
    public var paths: PathAccessController
    public var grants: [PathGrant]

    public init(
        paths: PathAccessController = .init(),
        grants: [PathGrant] = []
    ) {
        self.paths = paths
        self.grants = grants
    }

    public init(
        roots: [PathAccessRoot] = [],
        defaultRootIdentifier: PathAccessRootIdentifier? = nil,
        grants: [PathGrant] = []
    ) {
        self.init(
            paths: .init(
                roots: roots,
                defaultRootIdentifier: defaultRootIdentifier
            ),
            grants: grants
        )
    }
}

public extension WorkspaceAccessController {
    static func project(
        scope: PathAccessScope,
        id: PathAccessRootIdentifier = .project,
        label: String = "Project",
        details: String? = nil,
        grant: PathGrant? = nil
    ) -> Self {
        .init(
            paths: .project(
                scope: scope,
                identifier: id,
                label: label,
                details: details
            ),
            grants: [
                grant ?? .defaultProjectGrant(
                    rootID: id
                )
            ]
        )
    }

    var defaultRootID: PathAccessRootIdentifier? {
        paths.defaultRoot.identifier
    }

    var rootIdentifiers: [PathAccessRootIdentifier] {
        paths.rootIdentifiers
    }

    func root(
        id: PathAccessRootIdentifier
    ) throws -> PathAccessRoot {
        do {
            return try paths.root(
                identifier: id
            )
        } catch PathAccessControllerError.rootNotFound {
            throw WorkspaceAccessError.rootNotFound(
                id
            )
        }
    }

    func activeGrants(
        rootID: PathAccessRootIdentifier,
        capability: PathCapability,
        toolName: String?,
        at date: Date = Date()
    ) -> [PathGrant] {
        grants.filter {
            $0.allows(
                rootID: rootID,
                capability: capability,
                toolName: toolName,
                at: date
            )
        }
    }
}

public extension WorkspaceAccessController {
    func authorize(
        rootID: PathAccessRootIdentifier = .project,
        path rawPath: String,
        capability: PathCapability,
        toolName: String,
        filetype: AnyFileType? = nil,
        type: PathSegmentType? = nil,
        now: Date = Date()
    ) throws -> AgenticAuthorizedPath {
        let authorizedPath = try paths.authorize(
            rawPath,
            rootIdentifier: rootID,
            filetype: filetype,
            type: type
        )

        return try authorize(
            authorizedPath,
            capability: capability,
            toolName: toolName,
            now: now
        )
    }

    func authorize(
        rootID: PathAccessRootIdentifier = .project,
        scopedPath: ScopedPath,
        capability: PathCapability,
        toolName: String,
        type: PathSegmentType? = nil,
        now: Date = Date()
    ) throws -> AgenticAuthorizedPath {
        let authorizedPath = try paths.authorize(
            scopedPath,
            rootIdentifier: rootID,
            type: type
        )

        return try authorize(
            authorizedPath,
            capability: capability,
            toolName: toolName,
            now: now
        )
    }

    func authorize(
        rootID: PathAccessRootIdentifier = .project,
        url: URL,
        capability: PathCapability,
        toolName: String,
        type: PathSegmentType? = nil,
        now: Date = Date()
    ) throws -> AgenticAuthorizedPath {
        let authorizedPath = try paths.authorize(
            url,
            rootIdentifier: rootID,
            type: type
        )

        return try authorize(
            authorizedPath,
            capability: capability,
            toolName: toolName,
            now: now
        )
    }
}

public extension WorkspaceAccessController {
    func installing(
        root: PathAccessRoot,
        grant: PathGrant? = nil
    ) -> Self {
        var copy = self
        copy.paths = copy.paths.installing(
            root
        )

        if let grant {
            copy = copy.installingGrant(
                grant
            )
        }

        return copy
    }

    func installing(
        rootID: PathAccessRootIdentifier,
        label: String,
        scope: PathAccessScope,
        details: String? = nil,
        isDefault: Bool = false,
        grant: PathGrant? = nil
    ) -> Self {
        installing(
            root: .init(
                id: rootID,
                label: label,
                scope: scope,
                details: details,
                isDefault: isDefault
            ),
            grant: grant
        )
    }

    func replacingRootScope(
        rootID: PathAccessRootIdentifier,
        scope: PathAccessScope
    ) -> Self {
        var copy = self
        copy.paths = copy.paths.replacingRootScope(
            rootIdentifier: rootID,
            scope: scope
        )

        if rootID == .project,
           !copy.grants.contains(where: { $0.rootID == rootID }) {
            copy.grants.append(
                .defaultProjectGrant(
                    rootID: rootID
                )
            )
        }

        return copy
    }

    func removingRoot(
        id: PathAccessRootIdentifier,
        removeGrants: Bool = true
    ) -> Self {
        var copy = self
        copy.paths = copy.paths.removingRoot(
            identifier: id
        )

        if removeGrants {
            copy.grants.removeAll {
                $0.rootID == id
            }
        }

        return copy
    }

    func withDefaultRoot(
        _ rootID: PathAccessRootIdentifier
    ) throws -> Self {
        var copy = self
        copy.paths = try copy.paths.withDefaultRoot(
            rootID
        )
        return copy
    }

    func withPolicy(
        _ policy: PathAccessPolicy,
        rootID: PathAccessRootIdentifier? = nil
    ) throws -> Self {
        var copy = self
        copy.paths = try copy.paths.withPolicy(
            policy,
            rootIdentifier: rootID
        )
        return copy
    }

    func applying(
        _ patch: PathAccessPolicyPatch,
        rootID: PathAccessRootIdentifier? = nil
    ) throws -> Self {
        var copy = self
        copy.paths = try copy.paths.applying(
            patch,
            rootIdentifier: rootID
        )
        return copy
    }

    func installingGrant(
        _ grant: PathGrant
    ) -> Self {
        var copy = self
        copy.grants.removeAll {
            $0.id == grant.id
        }
        copy.grants.append(
            grant
        )
        return copy
    }

    func removingGrant(
        id: String
    ) -> Self {
        var copy = self
        copy.grants.removeAll {
            $0.id == id
        }
        return copy
    }
}

private extension WorkspaceAccessController {
    func authorize(
        _ authorizedPath: Path.AuthorizedPath,
        capability: PathCapability,
        toolName: String,
        now: Date
    ) throws -> AgenticAuthorizedPath {
        let grant = try requireGrant(
            rootID: authorizedPath.rootIdentifier,
            capability: capability,
            toolName: toolName,
            now: now
        )

        return .init(
            authorizedPath: authorizedPath,
            capability: capability,
            toolName: toolName,
            grantID: grant.id,
            agenticPolicyChecks: [
                "grant_allowed",
                "capability_allowed",
                "tool_allowed"
            ]
        )
    }

    func requireGrant(
        rootID: PathAccessRootIdentifier,
        capability: PathCapability,
        toolName: String,
        now: Date
    ) throws -> PathGrant {
        guard let grant = activeGrants(
            rootID: rootID,
            capability: capability,
            toolName: toolName,
            at: now
        ).first else {
            throw WorkspaceAccessError.grantDenied(
                rootID: rootID,
                capability: capability,
                toolName: toolName
            )
        }

        return grant
    }
}

public extension WorkspaceAccessController {
    func expiringGrants(
        at date: Date = Date()
    ) -> Self {
        var copy = self

        copy.grants.removeAll {
            $0.isExpired(
                at: date
            )
        }

        return copy
    }
}

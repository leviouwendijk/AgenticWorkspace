import Foundation
import Path
import Position
import Readers
import FileTypes
import Selection

public struct AgentWorkspace: Sendable, Codable, Equatable {
    public let accessController: WorkspaceAccessController

    public init(
        scope: PathAccessScope,
        accessController: WorkspaceAccessController? = nil
    ) {
        self.accessController = accessController ?? .project(
            scope: scope
        )
    }

    public init(
        root: StandardPath,
        accessPolicy: PathAccessPolicy = .defaults.workspace
    ) throws {
        let scope = try PathAccessScope(
            root: root,
            policy: accessPolicy
        )

        self.init(
            scope: scope
        )
    }

    public init(
        root: URL,
        accessPolicy: PathAccessPolicy = .defaults.workspace
    ) throws {
        let scope = try PathAccessScope(
            root: root,
            policy: accessPolicy
        )

        self.init(
            scope: scope
        )
    }
}

private extension AgentWorkspace {
    var defaultRoot: PathAccessRoot {
        do {
            return try accessController.paths.defaultRoot.root()
        } catch {
            preconditionFailure(
                "AgentWorkspace has no default PathAccessRoot: \(error)"
            )
        }
    }
}

public extension AgentWorkspace {
    var scope: PathAccessScope {
        defaultRoot.scope
    }

    var sandbox: PathSandbox {
        scope.sandbox
    }

    var accessPolicy: PathAccessPolicy {
        scope.policy
    }

    var root: StandardPath {
        defaultRoot.root
    }

    var rootURL: URL {
        defaultRoot.rootURL
    }
}

public extension AgentWorkspace {
    func withAccessController(
        _ accessController: WorkspaceAccessController
    ) -> Self {
        .init(
            scope: scope,
            accessController: accessController
        )
    }

    func withPolicy(
        _ policy: PathAccessPolicy
    ) -> Self {
        withProjectScope(
            scope.withPolicy(
                policy
            )
        )
    }

    func applying(
        _ patch: PathAccessPolicyPatch
    ) -> Self {
        withProjectScope(
            scope.applying(
                patch
            )
        )
    }

    func exceptions(
        @PathAccessRulePatternBuilder _ patterns: () -> [PathAccessRulePattern]
    ) -> Self {
        withProjectScope(
            scope.exceptions(
                patterns
            )
        )
    }

    func denials(
        @PathAccessRulePatternBuilder _ patterns: () -> [PathAccessRulePattern]
    ) -> Self {
        withProjectScope(
            scope.denials(
                patterns
            )
        )
    }

    func installingRoot(
        _ root: PathAccessRoot,
        grant: PathGrant? = nil
    ) -> Self {
        .init(
            scope: scope,
            accessController: accessController.installing(
                root: root,
                grant: grant
            )
        )
    }

    func installingRoot(
        id: PathAccessRootIdentifier,
        label: String,
        root: StandardPath,
        accessPolicy: PathAccessPolicy = .defaults.workspace,
        mode: PathGrantMode = .read_only,
        capabilities: [PathCapability] = [],
        allowedTools: [String] = [],
        details: String? = nil,
        reason: String? = nil,
        expiresAt: Date? = nil
    ) throws -> Self {
        let scope = try PathAccessScope(
            root: root,
            policy: accessPolicy
        )

        return installingRoot(
            .init(
                id: id,
                label: label,
                scope: scope,
                details: details,
                isDefault: false
            ),
            grant: .init(
                rootID: id,
                mode: mode,
                capabilities: capabilities,
                allowedTools: allowedTools,
                reason: reason,
                expiresAt: expiresAt
            )
        )
    }

    func installingRoot(
        id: PathAccessRootIdentifier,
        label: String,
        root: URL,
        accessPolicy: PathAccessPolicy = .defaults.workspace,
        mode: PathGrantMode = .read_only,
        capabilities: [PathCapability] = [],
        allowedTools: [String] = [],
        details: String? = nil,
        reason: String? = nil,
        expiresAt: Date? = nil
    ) throws -> Self {
        let scope = try PathAccessScope(
            root: root,
            policy: accessPolicy
        )

        return installingRoot(
            .init(
                id: id,
                label: label,
                scope: scope,
                details: details,
                isDefault: false
            ),
            grant: .init(
                rootID: id,
                mode: mode,
                capabilities: capabilities,
                allowedTools: allowedTools,
                reason: reason,
                expiresAt: expiresAt
            )
        )
    }

    func revokingRoot(
        id: PathAccessRootIdentifier,
        removeGrants: Bool = true
    ) -> Self {
        .init(
            scope: scope,
            accessController: accessController.removingRoot(
                id: id,
                removeGrants: removeGrants
            )
        )
    }

    func installingGrant(
        _ grant: PathGrant
    ) -> Self {
        .init(
            scope: scope,
            accessController: accessController.installingGrant(
                grant
            )
        )
    }

    func revokingGrant(
        id: String
    ) -> Self {
        .init(
            scope: scope,
            accessController: accessController.removingGrant(
                id: id
            )
        )
    }

    func expiringGrants(
        at date: Date = Date()
    ) -> Self {
        .init(
            scope: scope,
            accessController: accessController.expiringGrants(
                at: date
            )
        )
    }
}

private extension AgentWorkspace {
    func withProjectScope(
        _ scope: PathAccessScope
    ) -> Self {
        .init(
            scope: scope,
            accessController: accessController.replacingRootScope(
                rootID: .project,
                scope: scope
            )
        )
    }
}

public extension AgentWorkspace {
    func evaluateAccess(
        _ path: ScopedPath,
        type: PathSegmentType? = nil
    ) -> PathAccessEvaluation {
        if let scoped = try? scope(containing: path) {
            return scoped.evaluate(
                path,
                type: type
            )
        }

        return scope.evaluate(
            path,
            type: type
        )
    }

    @discardableResult
    func requireAccessible(
        _ path: ScopedPath,
        type: PathSegmentType? = nil
    ) throws -> ScopedPath {
        try scope(
            containing: path
        ).requireAccessible(
            path,
            type: type
        )
    }

    func resolve(
        _ path: StandardPath,
        type: PathSegmentType? = nil
    ) throws -> ScopedPath {
        try accessController.paths.resolve(
            path,
            rootIdentifier: nil,
            type: type
        )
    }

    func resolve(
        rootID: PathAccessRootIdentifier,
        _ path: StandardPath,
        type: PathSegmentType? = nil
    ) throws -> ScopedPath {
        try accessController.paths.resolve(
            path,
            rootIdentifier: rootID,
            type: type
        )
    }

    func resolve(
        rawPath: String,
        filetype: AnyFileType? = nil,
        type: PathSegmentType? = nil
    ) throws -> ScopedPath {
        try accessController.paths.resolve(
            rawPath,
            rootIdentifier: nil,
            filetype: filetype,
            type: type
        )
    }

    func resolve(
        rootID: PathAccessRootIdentifier,
        rawPath: String,
        filetype: AnyFileType? = nil,
        type: PathSegmentType? = nil
    ) throws -> ScopedPath {
        try accessController.paths.resolve(
            rawPath,
            rootIdentifier: rootID,
            filetype: filetype,
            type: type
        )
    }

    func resolve(
        _ rawPath: String,
        filetype: AnyFileType? = nil,
        type: PathSegmentType? = nil
    ) throws -> ScopedPath {
        try accessController.paths.resolve(
            rawPath,
            rootIdentifier: nil,
            filetype: filetype,
            type: type
        )
    }

    func resolve(
        rootID: PathAccessRootIdentifier,
        _ rawPath: String,
        filetype: AnyFileType? = nil,
        type: PathSegmentType? = nil
    ) throws -> ScopedPath {
        try accessController.paths.resolve(
            rawPath,
            rootIdentifier: rootID,
            filetype: filetype,
            type: type
        )
    }

    func scope(
        _ url: URL,
        type: PathSegmentType? = nil
    ) throws -> ScopedPath {
        try accessController.paths.scope(
            url,
            rootIdentifier: nil,
            type: type
        )
    }

    func scope(
        rootID: PathAccessRootIdentifier,
        _ url: URL,
        type: PathSegmentType? = nil
    ) throws -> ScopedPath {
        try accessController.paths.scope(
            url,
            rootIdentifier: rootID,
            type: type
        )
    }

    func absoluteURL(
        for path: ScopedPath,
        type: PathSegmentType? = nil
    ) throws -> URL {
        let scoped = try requireAccessible(
            path,
            type: type
        )

        return try scope(
            containing: scoped
        ).absoluteURL(
            for: scoped,
            type: type
        )
    }

    func existingType(
        of path: ScopedPath
    ) throws -> PathSegmentType? {
        try scope(
            containing: path
        ).existingType(
            of: path
        )
    }

    func contains(
        _ path: ScopedPath,
        type: PathSegmentType? = nil
    ) -> Bool {
        (try? requireAccessible(
            path,
            type: type
        )) != nil
    }

    func contains(
        _ path: StandardPath,
        type: PathSegmentType? = nil
    ) -> Bool {
        (try? accessController.paths.authorize(
            path,
            rootIdentifier: nil,
            type: type
        )) != nil
    }
}

public extension AgentWorkspace {
    func read(
        _ path: ScopedPath,
        encoding: String.Encoding = .utf8
    ) throws -> ScopedWorkspaceRead {
        try read(
            path,
            options: .init(
                decoding: .exact(
                    .init(encoding)
                ),
                missingFilePolicy: .throwError,
                newlineNormalization: .unix
            )
        )
    }

    func read(
        _ path: ScopedPath,
        options: TextReadOptions = .init(
            decoding: .commonTextFallbacks,
            missingFilePolicy: .throwError,
            newlineNormalization: .unix
        )
    ) throws -> ScopedWorkspaceRead {
        let path = try requireAccessible(
            path,
            type: .file
        )
        let result = try TextFileReader(
            try absoluteURL(
                for: path,
                type: .file
            )
        ).read(
            options: options
        )

        return .init(
            path: path,
            text: result.text,
            encodingUsed: result.encodingUsed,
            byteCount: result.byteCount,
            existed: result.existed
        )
    }

    func readLines(
        _ path: ScopedPath,
        options: LineReadOptions = .default
    ) throws -> ScopedWorkspaceLineRead {
        let path = try requireAccessible(
            path,
            type: .file
        )
        let result = try LineReader(
            try absoluteURL(
                for: path,
                type: .file
            )
        ).read(
            options: options
        )

        return .init(
            path: path,
            lines: result.lines,
            encodingUsed: result.encodingUsed,
            byteCount: result.byteCount,
            existed: result.existed
        )
    }

    func readSlice(
        _ path: ScopedPath,
        range: LineRange?,
        maxLines: Int? = nil,
        options: LineReadOptions = .default
    ) throws -> ScopedWorkspaceLineSliceRead {
        let path = try requireAccessible(
            path,
            type: .file
        )
        let result = try LineReader(
            try absoluteURL(
                for: path,
                type: .file
            )
        ).readSlice(
            range: range,
            maxLines: maxLines,
            options: options
        )

        return .init(
            path: path,
            selectedLines: result.selectedLines,
            selectedLineRange: result.selectedLineRange,
            totalLineCount: result.totalLineCount,
            truncated: result.truncated,
            encodingUsed: result.encodingUsed,
            byteCount: result.byteCount,
            existed: result.existed
        )
    }

    func readSlice(
        _ path: ScopedPath,
        startLine: Int? = nil,
        endLine: Int? = nil,
        maxLines: Int? = nil,
        options: LineReadOptions = .default
    ) throws -> ScopedWorkspaceLineSliceRead {
        let path = try requireAccessible(
            path,
            type: .file
        )
        let result = try LineReader(
            try absoluteURL(
                for: path,
                type: .file
            )
        ).readSlice(
            startLine: startLine,
            endLine: endLine,
            maxLines: maxLines,
            options: options
        )

        return .init(
            path: path,
            selectedLines: result.selectedLines,
            selectedLineRange: result.selectedLineRange,
            totalLineCount: result.totalLineCount,
            truncated: result.truncated,
            encodingUsed: result.encodingUsed,
            byteCount: result.byteCount,
            existed: result.existed
        )
    }

    func readData(
        _ path: ScopedPath,
        options: DataReadOptions = .default
    ) throws -> ScopedWorkspaceDataRead {
        let path = try requireAccessible(
            path,
            type: .file
        )
        let result = try DataFileReader(
            try absoluteURL(
                for: path,
                type: .file
            )
        ).read(
            options: options
        )

        return .init(
            path: path,
            data: result.data,
            byteCount: result.byteCount,
            existed: result.existed
        )
    }

    func readBase64(
        _ path: ScopedPath,
        options: DataReadOptions = .default
    ) throws -> ScopedWorkspaceBase64Read {
        let path = try requireAccessible(
            path,
            type: .file
        )
        let result = try DataFileReader(
            try absoluteURL(
                for: path,
                type: .file
            )
        ).readBase64(
            options: options
        )

        return .init(
            path: path,
            base64: result.base64,
            mediaType: result.mediaType,
            byteCount: result.byteCount,
            existed: result.existed
        )
    }

    func readSelection(
        _ path: ScopedPath,
        _ selection: ContentSelection,
        options: LineReadOptions = .default
    ) throws -> ScopedWorkspaceSelectionRead {
        try readSelections(
            path,
            [
                selection
            ],
            options: options
        )
    }

    func readSelections(
        _ path: ScopedPath,
        _ selections: [ContentSelection],
        options: LineReadOptions = .default
    ) throws -> ScopedWorkspaceSelectionRead {
        let path = try requireAccessible(
            path,
            type: .file
        )
        let url = try absoluteURL(
            for: path,
            type: .file
        )
        let readResult = try LineReader(url).read(
            options: options
        )
        let resolved = SelectionResolver.resolve(
            file: url,
            readResult: readResult,
            selections: selections
        )

        return .init(
            path: path,
            resolved: resolved
        )
    }

    func scan(
        _ specification: PathScanSpecification,
        rootID: PathAccessRootIdentifier? = nil,
        configuration: PathWalkConfiguration = .init()
    ) throws -> PathScanResult {
        let root = try accessController.paths.root(
            identifier: rootID
        )
        let result = try PathScan.scan(
            specification,
            relativeTo: .directoryURL(root.rootURL),
            configuration: configuration
        )

        return .init(
            matches: root.scope.filteredMatches(
                from: result
            ),
            warnings: result.warnings
        )
    }

    func scopedEntries(
        from result: PathScanResult,
        excluding scannedPath: ScopedPath? = nil,
        rootID: PathAccessRootIdentifier? = nil
    ) -> [ScopedWorkspaceScan.Entry] {
        guard let root = try? accessController.paths.root(
            identifier: rootID
        ) else {
            return []
        }

        return result.matches.compactMap { match in
            guard let scoped = root.scope.scopedPath(
                from: match
            ) else {
                return nil
            }

            if let scannedPath,
               scoped.root == scannedPath.root,
               scoped.relative == scannedPath.relative {
                return nil
            }

            guard (try? root.scope.requireAccessible(
                scoped,
                type: match.type
            )) != nil else {
                return nil
            }

            return .init(
                path: scoped,
                isDirectory: match.type == .directory
            )
        }
    }

    func authorizedEntries(
        from result: PathScanResult,
        rootID: PathAccessRootIdentifier,
        capability: PathCapability,
        toolName: String,
        excluding scannedPath: ScopedPath? = nil
    ) throws -> [ScopedWorkspaceScan.Entry] {
        let root = try accessController.root(
            id: rootID
        )

        return result.matches.compactMap { match in
            guard let scoped = root.scope.scopedPath(
                from: match
            ) else {
                return nil
            }

            if let scannedPath,
               scoped.root == scannedPath.root,
               scoped.relative == scannedPath.relative {
                return nil
            }

            guard let authorized = try? accessController.authorize(
                rootID: root.id,
                scopedPath: scoped,
                capability: capability,
                toolName: toolName,
                type: match.type
            ) else {
                return nil
            }

            return .init(
                path: authorized.scopedPath,
                isDirectory: match.type == .directory
            )
        }
    }
}

private extension AgentWorkspace {
    func root(
        containing path: ScopedPath
    ) throws -> PathAccessRoot {
        let roots = accessController.paths.roots.values.sorted {
            $0.id.rawValue < $1.id.rawValue
        }

        guard let root = roots.first(where: { candidate in
            candidate.scope.sandbox.contains(
                path
            )
        }) else {
            throw WorkspaceAccessError.scopedPathRootNotFound(
                path.presentingRelative(
                    filetype: true
                )
            )
        }

        return root
    }

    func scope(
        containing path: ScopedPath
    ) throws -> PathAccessScope {
        try root(
            containing: path
        ).scope
    }
}

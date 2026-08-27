import Agentic
import Foundation
import Path

public struct PathGrant: Sendable, Codable, Hashable, Identifiable {
    public var id: String
    public var rootID: PathAccessRootIdentifier
    public var mode: PathGrantMode
    public var capabilities: [PathCapability]
    public var allowedTools: [String]
    public var reason: String?
    public var expiresAt: Date?
    public var sourcePreparedIntentID: PreparedIntentIdentifier?
    public var metadata: [String: String]

    public init(
        id: String = UUID().uuidString,
        rootID: PathAccessRootIdentifier,
        mode: PathGrantMode,
        capabilities: [PathCapability] = [],
        allowedTools: [String] = [],
        reason: String? = nil,
        expiresAt: Date? = nil,
        sourcePreparedIntentID: PreparedIntentIdentifier? = nil,
        metadata: [String: String] = [:]
    ) {
        self.id = id
        self.rootID = rootID
        self.mode = mode
        self.capabilities = capabilities.isEmpty
            ? mode.defaultCapabilities.orderedByDeclaration
            : capabilities
        self.allowedTools = allowedTools
        self.reason = reason
        self.expiresAt = expiresAt
        self.sourcePreparedIntentID = sourcePreparedIntentID
        self.metadata = metadata
    }
}

public extension PathGrant {
    static func defaultProjectGrant(
        rootID: PathAccessRootIdentifier = .project,
        allowedTools: [String] = []
    ) -> Self {
        .init(
            id: "default-\(rootID.rawValue)",
            rootID: rootID,
            mode: .read_write,
            allowedTools: allowedTools,
            reason: "Default project workspace access."
        )
    }

    func allows(
        rootID: PathAccessRootIdentifier,
        capability: PathCapability,
        toolName: String?,
        at date: Date = Date()
    ) -> Bool {
        guard self.rootID == rootID else {
            return false
        }

        if let expiresAt,
           expiresAt <= date {
            return false
        }

        guard capabilities.contains(capability) else {
            return false
        }

        guard let toolName,
              !allowedTools.isEmpty
        else {
            return true
        }

        return allowedTools.contains(toolName)
    }
}

private extension Set where Element == PathCapability {
    var orderedByDeclaration: [PathCapability] {
        PathCapability.allCases.filter {
            contains($0)
        }
    }
}

public extension PathGrant {
    func isExpired(
        at date: Date = Date()
    ) -> Bool {
        guard let expiresAt else {
            return false
        }

        return expiresAt <= date
    }
}

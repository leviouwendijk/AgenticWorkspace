import Foundation
import Path

public struct AgenticAuthorizedPath: Sendable, Codable, Hashable {
    public let authorizedPath: Path.AuthorizedPath
    public let capability: PathCapability
    public let toolName: String
    public let grantID: String?
    public let agenticPolicyChecks: [String]

    public init(
        authorizedPath: Path.AuthorizedPath,
        capability: PathCapability,
        toolName: String,
        grantID: String? = nil,
        agenticPolicyChecks: [String] = []
    ) {
        self.authorizedPath = authorizedPath
        self.capability = capability
        self.toolName = toolName
        self.grantID = grantID
        self.agenticPolicyChecks = agenticPolicyChecks
    }
}

public extension AgenticAuthorizedPath {
    var rootIdentifier: PathAccessRootIdentifier {
        authorizedPath.rootIdentifier
    }

    var rootID: PathAccessRootIdentifier {
        rootIdentifier
    }

    var scopedPath: ScopedPath {
        authorizedPath.scopedPath
    }

    var absoluteURL: URL {
        authorizedPath.absoluteURL
    }

    var presentationPath: String {
        authorizedPath.presentationPath
    }

    var qualifiedPresentationPath: String {
        authorizedPath.qualifiedPresentationPath
    }

    var evaluation: PathAccessEvaluation {
        authorizedPath.evaluation
    }

    var policyChecks: [String] {
        authorizedPath.policyChecks + agenticPolicyChecks
    }
}

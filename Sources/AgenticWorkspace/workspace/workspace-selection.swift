import Foundation
import Path
import PathParsing

public struct WorkspaceSelection:
    Sendable,
    Codable,
    Hashable
{
    public let exactPaths: [PathPattern]
    public let includes: [PathPattern]
    public let excludes: [PathPattern]

    private init(
        exactPaths: [PathPattern],
        includes: [PathPattern],
        excludes: [PathPattern]
    ) {
        self.exactPaths = exactPaths
        self.includes = includes
        self.excludes = excludes
    }

    public init(
        exactPaths: [String] = [],
        includeExpressions: [String] = [],
        excludeExpressions: [String] = []
    ) throws {
        self.init(
            exactPaths: try exactPaths.map(
                Self.exactPattern
            ),
            includes: try includeExpressions.map(
                Self.relativePattern
            ),
            excludes: try excludeExpressions.map(
                Self.relativePattern
            )
        )
    }

    public static let all = Self(
        exactPaths: [],
        includes: [],
        excludes: []
    )

    public var isAll: Bool {
        exactPaths.isEmpty
            && includes.isEmpty
            && excludes.isEmpty
    }

    public func allows(
        _ path: DescendantPath,
        type: PathSegmentType? = nil
    ) -> Bool {
        guard !matches(
            excludes,
            path: path,
            type: type
        ) else {
            return false
        }

        guard !exactPaths.isEmpty || !includes.isEmpty else {
            return true
        }

        return matchesExact(
            exactPaths,
            path: path,
            type: type
        ) || matches(
            includes,
            path: path,
            type: type
        )
    }
}

private extension WorkspaceSelection {
    static func exactPattern(
        _ rawValue: String
    ) throws -> PathPattern {
        let expression = try relativeExpression(
            rawValue
        )

        guard !expression.containsPatternSyntax else {
            throw WorkspaceSelectionError.patternedExactPath(
                rawValue
            )
        }

        return expression.pattern
    }

    static func relativePattern(
        _ rawValue: String
    ) throws -> PathPattern {
        try relativeExpression(
            rawValue
        ).pattern
    }

    static func relativeExpression(
        _ rawValue: String
    ) throws -> PathExpression {
        let expression = try PathParse.expression(
            rawValue
        )

        guard expression.anchor == .relative else {
            throw WorkspaceSelectionError.nonRelativeExpression(
                rawValue
            )
        }

        return expression
    }

    func matchesExact(
        _ patterns: [PathPattern],
        path: DescendantPath,
        type: PathSegmentType?
    ) -> Bool {
        patterns.contains { pattern in
            guard !pattern.containsPatternSyntax else {
                return false
            }

            return PathAccessMatcher
                .expression(
                    PathExpression(
                        pattern: pattern
                    )
                )
                .matches(
                    path,
                    type: type
                )
        }
    }

    func matches(
        _ patterns: [PathPattern],
        path: DescendantPath,
        type: PathSegmentType?
    ) -> Bool {
        patterns.contains { pattern in
            PathAccessMatcher
                .expression(
                    PathExpression(
                        pattern: pattern
                    )
                )
                .matches(
                    path,
                    type: type
                )
        }
    }
}

public enum WorkspaceSelectionError:
    Error,
    Sendable,
    LocalizedError,
    Equatable
{
    case nonRelativeExpression(String)
    case patternedExactPath(String)

    public var errorDescription: String? {
        switch self {
        case .nonRelativeExpression(let value):
            return "Workspace selection expression '\(value)' must be relative to its workspace root."

        case .patternedExactPath(let value):
            return "Workspace exact path '\(value)' must not contain pattern syntax."
        }
    }
}

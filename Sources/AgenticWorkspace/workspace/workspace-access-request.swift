import Foundation

public enum PathGrantLifetime:
    String,
    Sendable,
    Codable,
    Hashable,
    CaseIterable
{
    case turn
    case session
}

public struct WorkspaceAccessRequest:
    Sendable,
    Codable,
    Hashable
{
    public let overlay: WorkspaceAccessOverlay
    public let durationSeconds: TimeInterval?

    public init(
        overlay: WorkspaceAccessOverlay,
        durationSeconds: TimeInterval? = nil
    ) {
        self.overlay = overlay
        self.durationSeconds = durationSeconds
    }
}

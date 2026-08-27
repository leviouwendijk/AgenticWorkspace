import Path

public extension PathAccessPolicy {
    @available(*, deprecated, renamed: "defaults.workspace")
    static var agenticWorkspaceDefault: Self {
        .defaults.workspace
    }
}

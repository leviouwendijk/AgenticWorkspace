public extension AgentWorkspace {
    func applying(
        _ overlay: WorkspaceAccessOverlay
    ) throws -> Self {
        var controller = accessController
        var rootIDs = Set(
            controller.rootIdentifiers
        )
        var grantIDs = Set(
            controller.grants.map(\.id)
        )

        for grantedRoot in overlay.roots {
            let rootID = grantedRoot.root.id

            guard rootIDs.insert(rootID).inserted else {
                throw WorkspaceAccessOverlayError.root_already_present(
                    rootID
                )
            }
            guard grantIDs.insert(grantedRoot.grant.id).inserted else {
                throw WorkspaceAccessOverlayError.grant_already_present(
                    grantedRoot.grant.id
                )
            }

            controller = controller.installing(
                root: grantedRoot.root,
                grant: grantedRoot.grant,
                selection: grantedRoot.selection
            )
        }

        for grant in overlay.grants {
            guard rootIDs.contains(grant.rootID) else {
                throw WorkspaceAccessOverlayError.grant_root_unavailable(
                    grant.rootID
                )
            }
            guard grantIDs.insert(grant.id).inserted else {
                throw WorkspaceAccessOverlayError.grant_already_present(
                    grant.id
                )
            }

            controller = controller.installingGrant(
                grant
            )
        }

        return withAccessController(
            controller
        )
    }

    func applying(
        _ overlays: [WorkspaceAccessOverlay]
    ) throws -> Self {
        var workspace = self

        for overlay in overlays {
            workspace = try workspace.applying(
                overlay
            )
        }

        return workspace
    }
}

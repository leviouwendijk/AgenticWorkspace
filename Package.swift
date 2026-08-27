// swift-tools-version: 6.3

import PackageDescription

let package = Package(
    name: "AgenticWorkspace",
    platforms: [
        .macOS(.v13),
    ],
    products: [
        .library(
            name: "AgenticWorkspace",
            targets: [
                "AgenticWorkspace",
            ]
        ),
    ],
    dependencies: [
        .package(
            url: "https://github.com/leviouwendijk/Agentic.git",
            branch: "master"
        ),
        .package(
            url: "https://github.com/leviouwendijk/Path.git",
            branch: "master"
        ),
        .package(
            url: "https://github.com/leviouwendijk/Position.git",
            branch: "master"
        ),
        .package(
            url: "https://github.com/leviouwendijk/Readers.git",
            branch: "master"
        ),
        .package(
            url: "https://github.com/leviouwendijk/FileTypes.git",
            branch: "master"
        ),
        .package(
            url: "https://github.com/leviouwendijk/Selection.git",
            branch: "master"
        ),
    ],
    targets: [
        .target(
            name: "AgenticWorkspace",
            dependencies: [
                .product(
                    name: "Agentic",
                    package: "Agentic"
                ),
                .product(
                    name: "Path",
                    package: "Path"
                ),
                .product(
                    name: "Position",
                    package: "Position"
                ),
                .product(
                    name: "Readers",
                    package: "Readers"
                ),
                .product(
                    name: "FileTypes",
                    package: "FileTypes"
                ),
                .product(
                    name: "Selection",
                    package: "Selection"
                ),
            ]
        ),
    ],
    swiftLanguageModes: [
        .v6,
    ]
)

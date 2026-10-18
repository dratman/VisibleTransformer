// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "VisibleTransformer",
    platforms: [.macOS(.v14)],
    targets: [
        // Shared model code (no graphics).
        .target(name: "VisibleTransformer", path: "Sources/VisibleTransformer"),
        // Prototype 1: a row of characters with embedding lines above them.
        .executableTarget(
            name: "EmbeddingRow",
            dependencies: ["VisibleTransformer"],
            path: "Sources/EmbeddingRow"
        ),
    ]
)

// swift-tools-version: 6.1
import PackageDescription

let package = Package(
    name: "music_agent",
    platforms: [
        .macOS(.v15)
    ],
    products: [
        .library(
            name: "AppleMusicKit",
            targets: ["AppleMusicKit"]
        ),
        .library(
            name: "SonosKit",
            targets: ["SonosKit"]
        ),
        .library(
            name: "AmplifierKit",
            targets: ["AmplifierKit"]
        ),
        .library(
            name: "OpenURLKit",
            targets: ["OpenURLKit"]
        ),
        .executable(
            name: "AppleMusicCLI",
            targets: ["AppleMusicCLI"]
        ),
        .executable(
            name: "SonosCLI",
            targets: ["SonosCLI"]
        ),
        .executable(
            name: "AmplifierCLI",
            targets: ["AmplifierCLI"]
        ),
        .executable(
            name: "OpenURLCLI",
            targets: ["OpenURLCLI"]
        ),
        .executable(
            name: "AppleMusicTool",
            targets: ["AppleMusicTool"]
        ),
        .executable(
            name: "SonosTool",
            targets: ["SonosTool"]
        ),
        .executable(
            name: "AmplifierTool",
            targets: ["AmplifierTool"]
        ),
        .executable(
            name: "OpenURLTool",
            targets: ["OpenURLTool"]
        ),
        .executable(
            name: "BedrockCLI",
            targets: ["BedrockCLI"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-log.git", from: "1.6.3"),
        .package(url: "https://github.com/apple/swift-argument-parser", from: "1.2.0"),
        .package(url: "https://github.com/vapor/jwt-kit.git", from: "5.0.0"),
        // .package(url: "https://github.com/modelcontextprotocol/swift-sdk.git", branch: "main"),
        // .package(url: "https://github.com/build-on-aws/swift-fm-playground.git", branch: "merge_repos"),
        .package(path: "../swift-fm-playground"),
        .package(path: "../mcpserverkit"),
    ],
    targets: [
        .target(
            name: "AppleMusicKit",
            dependencies: [
                .product(name: "JWTKit", package: "jwt-kit")
            ]
        ),
        .target(
            name: "SonosKit",
            dependencies: []
        ),
        .target(
            name: "AmplifierKit",
            dependencies: []
        ),
        .target(
            name: "OpenURLKit",
            dependencies: []
        ),
        .executableTarget(
            name: "AppleMusicCLI",
            dependencies: [
                "AppleMusicKit",
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
            ]
        ),
        .executableTarget(
            name: "SonosCLI",
            dependencies: [
                "SonosKit",
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
            ]
        ),
        .executableTarget(
            name: "AmplifierCLI",
            dependencies: [
                "AmplifierKit",
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
            ]
        ),
        .executableTarget(
            name: "OpenURLCLI",
            dependencies: [
                "OpenURLKit",
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
            ]
        ),
        .executableTarget(
            name: "AppleMusicTool",
            dependencies: [
                "AppleMusicKit",
                .product(name: "MCPServerKit", package: "mcpserverkit"),
            ]
        ),
        .executableTarget(
            name: "SonosTool",
            dependencies: [
                "SonosKit",
                .product(name: "MCPServerKit", package: "mcpserverkit"),
            ]
        ),
        .executableTarget(
            name: "AmplifierTool",
            dependencies: [
                "AmplifierKit",
                .product(name: "MCPServerKit", package: "mcpserverkit"),
            ]
        ),
        .executableTarget(
            name: "OpenURLTool",
            dependencies: [
                "OpenURLKit",
                .product(name: "MCPServerKit", package: "mcpserverkit"),
            ]
        ),
        .executableTarget(
            name: "BedrockCLI",
            dependencies: [
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
                .product(name: "Logging", package: "swift-log"),
                .product(name: "BedrockService", package: "swift-fm-playground"),
                .product(name: "BedrockTypes", package: "swift-fm-playground"),
                .product(name: "MCPClientKit", package: "mcpserverkit"),
                "AppleMusicKit", "OpenURLKit"
            ]
        ),
        .testTarget(
            name: "AppleMusicKitTests",
            dependencies: ["AppleMusicKit"]
        ),
        .testTarget(
            name: "SonosKitTests",
            dependencies: ["SonosKit"]
        ),
        .testTarget(
            name: "AmplifierKitTests",
            dependencies: ["AmplifierKit"]
        ),
        .testTarget(
            name: "OpenURLKitTests",
            dependencies: [ "OpenURLKit"]
        ),
    ]
)

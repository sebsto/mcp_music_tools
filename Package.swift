// swift-tools-version: 6.0
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
        .executable(
            name: "AppleMusicCLI",
            targets: ["AppleMusicCLI"]
        ),
        .executable(
            name: "SonosCLI",
            targets: ["SonosCLI"]
        ),
        .executable(
            name: "AppleMusicTool",
            targets: ["AppleMusicTool"]
        ),
        .executable(
            name: "SonosTool",
            targets: ["SonosTool"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser", from: "1.2.0"),
        .package(url: "https://github.com/vapor/jwt-kit.git", from: "5.0.0"),
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
        .testTarget(
            name: "AppleMusicKitTests",
            dependencies: ["AppleMusicKit"]
        ),
        .testTarget(
            name: "SonosKitTests",
            dependencies: ["SonosKit"]
        ),
    ]
)

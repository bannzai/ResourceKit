// swift-tools-version:4.0
import PackageDescription

let package = Package(
    name: "ResourceKit",
    dependencies: [
        .package(url: "https://github.com/bannzai/XcodeProject.git", from: Version(0, 1, 1)),
        .package(url: "https://github.com/kylef/Commander.git", from: Version(0, 8, 0)),
    ],
    targets: [
        .target(
            name: "ResourceKit",
            dependencies: ["ResourceKitCore"]
        ),
        .target(
            name: "ResourceKitCore",
            dependencies: ["XcodeProject", "Commander"]
        ),
        .testTarget(name: "ResourceKitCoreTests", dependencies: ["ResourceKitCore"]),
        ],
    swiftLanguageVersions: [4]
)

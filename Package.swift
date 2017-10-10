import PackageDescription

let package = Package(
    name: "ResourceKit",
    targets: [
        Target(
            name: "ResourceKit"
        ),
    ],
    dependencies: [
        .Package(url: "git@github.com:bannzai/XcodeProject.git", "0.1.0"),
    ]
)


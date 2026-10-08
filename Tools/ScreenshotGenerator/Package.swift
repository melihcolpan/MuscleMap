// swift-tools-version: 5.9

import PackageDescription

// Renders the README screenshots from code:
//   swift run --package-path Tools/ScreenshotGenerator ScreenshotGenerator Screenshots
let package = Package(
    name: "ScreenshotGenerator",
    platforms: [.macOS(.v14)],
    dependencies: [
        .package(name: "MuscleMap", path: "../..")
    ],
    targets: [
        .executableTarget(
            name: "ScreenshotGenerator",
            dependencies: ["MuscleMap"]
        )
    ]
)

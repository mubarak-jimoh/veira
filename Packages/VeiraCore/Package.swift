// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "VeiraCore",
    platforms: [
        .iOS(.v18),
        .macOS(.v14)
    ],
    products: [
        .library(name: "VeiraCore", targets: ["VeiraCore"])
    ],
    targets: [
        .target(
            name: "VeiraCore",
            path: "Sources/VeiraCore"
        ),
        .testTarget(
            name: "VeiraCoreTests",
            dependencies: ["VeiraCore"],
            path: "Tests/VeiraCoreTests"
        )
    ]
)

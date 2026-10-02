// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "VeiraDomain",
    platforms: [
        .iOS(.v18),
        .macOS(.v14)
    ],
    products: [
        .library(name: "VeiraDomain", targets: ["VeiraDomain"])
    ],
    dependencies: [
        .package(path: "../VeiraCore")
    ],
    targets: [
        .target(
            name: "VeiraDomain",
            dependencies: ["VeiraCore"],
            path: "Sources/VeiraDomain"
        ),
        .testTarget(
            name: "VeiraDomainTests",
            dependencies: ["VeiraDomain"],
            path: "Tests/VeiraDomainTests"
        )
    ]
)

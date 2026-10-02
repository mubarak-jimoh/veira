// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "VeiraNetworking",
    platforms: [
        .iOS(.v18),
        .macOS(.v14)
    ],
    products: [
        .library(name: "VeiraNetworking", targets: ["VeiraNetworking"])
    ],
    dependencies: [
        .package(path: "../VeiraCore")
    ],
    targets: [
        .target(
            name: "VeiraNetworking",
            dependencies: ["VeiraCore"],
            path: "Sources/VeiraNetworking"
        ),
        .testTarget(
            name: "VeiraNetworkingTests",
            dependencies: ["VeiraNetworking"],
            path: "Tests/VeiraNetworkingTests"
        )
    ]
)

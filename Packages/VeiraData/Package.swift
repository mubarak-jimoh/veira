// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "VeiraData",
    platforms: [
        .iOS(.v18),
        .macOS(.v14)
    ],
    products: [
        .library(name: "VeiraData", targets: ["VeiraData"])
    ],
    dependencies: [
        .package(path: "../VeiraCore"),
        .package(path: "../VeiraDomain"),
        .package(path: "../VeiraNetworking")
    ],
    targets: [
        .target(
            name: "VeiraData",
            dependencies: [
                "VeiraCore",
                "VeiraDomain",
                "VeiraNetworking"
            ],
            path: "Sources/VeiraData"
        ),
        .testTarget(
            name: "VeiraDataTests",
            dependencies: ["VeiraData"],
            path: "Tests/VeiraDataTests"
        )
    ]
)

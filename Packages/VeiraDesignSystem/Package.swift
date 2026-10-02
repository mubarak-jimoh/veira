// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "VeiraDesignSystem",
    platforms: [
        .iOS(.v18)
    ],
    products: [
        .library(name: "VeiraDesignSystem", targets: ["VeiraDesignSystem"])
    ],
    targets: [
        .target(
            name: "VeiraDesignSystem",
            path: "Sources/VeiraDesignSystem"
        ),
        .testTarget(
            name: "VeiraDesignSystemTests",
            dependencies: ["VeiraDesignSystem"],
            path: "Tests/VeiraDesignSystemTests"
        )
    ]
)

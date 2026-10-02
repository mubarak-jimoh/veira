// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "VeiraStoreKit",
    platforms: [
        .iOS(.v18),
        .macOS(.v14)
    ],
    products: [
        .library(name: "VeiraStoreKit", targets: ["VeiraStoreKit"])
    ],
    dependencies: [
        .package(path: "../VeiraCore"),
        .package(path: "../VeiraDomain")
    ],
    targets: [
        .target(
            name: "VeiraStoreKit",
            dependencies: [
                "VeiraCore",
                "VeiraDomain"
            ],
            path: "Sources/VeiraStoreKit"
        ),
        .testTarget(
            name: "VeiraStoreKitTests",
            dependencies: ["VeiraStoreKit"],
            path: "Tests/VeiraStoreKitTests"
        )
    ]
)

// swift-tools-version: 5.7

import PackageDescription

let package = Package(
    name: "KetchSDK",
    platforms: [
        .iOS(.v14)
    ],
    products: [
        .library(
            name: "KetchSDK",
            targets: ["KetchSDK"]
        ),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "KetchSDK",
            dependencies: []
        ),
        .testTarget(
            name: "KetchSDKTests",
            dependencies: ["KetchSDK"]),
    ]
)

// swift-tools-version:5.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Ketch",
    platforms: [
      .iOS(.v13)
    ],
    products: [
        // Products define the executables and libraries produced by a package, and make them visible to other packages.
        .library(
            name: "Ketch",
            targets: ["Ketch"]),
    ],
    dependencies: [
        .package(url: "https://github.com/grpc/grpc-swift.git", .revision("e2e138df61dcbfc2dc1cf284fdab6f983539ab48"))
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.
        .target(
            name: "Ketch",
            dependencies: [.product(name: "GRPC", package: "grpc-swift")],
            exclude: ["Sample", "scripts"]),
        .testTarget(
            name: "KetchTests",
            dependencies: ["Ketch"],
            exclude: ["Sample", "scripts"]),
    ]
)


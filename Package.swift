// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Reach5Google",
    products: [
        .library(name: "Reach5Google", targets: ["Reach5Google"]),
    ],
    dependencies: [
        .package(url: "https://github.com/ReachFive/reachfive-ios.git", branch: "7.0.0"),
        .package(url: "https://github.com/google/GoogleSignIn-iOS.git", .upToNextMajor(from: "7.1.0")),
    ],
    targets: [
        .target(
            name: "Reach5Google",
            dependencies: [
                .product(name: "Reach5", package: "reachfive-ios"),
                .product(name: "GoogleSignIn", package: "GoogleSignIn-iOS"),
            ],
            path: "IdentitySdkGoogle"),
    ]
)

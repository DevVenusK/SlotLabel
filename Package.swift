// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "RollingNumberLabel",
    platforms: [
        .iOS(.v15)
    ],
    products: [
        .library(
            name: "RollingNumberLabel",
            targets: ["RollingNumberLabel"]
        ),
    ],
    targets: [
        .target(
            name: "RollingNumberLabel",
            path: "Sources/RollingNumberLabel"
        ),
        .testTarget(
            name: "RollingNumberLabelTests",
            dependencies: ["RollingNumberLabel"],
            path: "Tests/RollingNumberLabelTests"
        ),
    ],
    swiftLanguageVersions: [.v6]
)

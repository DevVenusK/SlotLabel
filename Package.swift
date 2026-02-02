// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "RollingNumberLabel",
    platforms: [
        .iOS(.v13)
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
    ],
    swiftLanguageVersions: [.v5]
)

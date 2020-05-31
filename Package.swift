// swift-tools-version:5.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Resolve",
    platforms: [
        .macOS(.v10_15),
        .iOS(.v13),
        .tvOS(.v13),
        .watchOS(.v6),
    ],
    products: [
        .library(name: "Resolve", targets: ["Resolve"]),
    ],
    dependencies: [],
    targets: [
        .target(name: "Resolve", dependencies: []),
        .testTarget(name: "ResolveTests", dependencies: ["Resolve"]),
    ]
)

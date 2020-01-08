// swift-tools-version:5.1

import PackageDescription

let package = Package(
    name: "StateTransition",
    platforms: [
        .macOS(.v10_15),
        .iOS(.v13),
        .tvOS(.v13),
        .watchOS(.v6)
    ],
    products: [
        .library(name: "StateTransition", targets: ["StateTransition"]),
    ],
    dependencies: [],
    targets: [
        .target(name: "StateTransition", dependencies: [], path: "StateTransition"),
        .testTarget(name: "StateTransitionTests", dependencies: ["StateTransition"], path: "StateTransitionTests"),
    ]
)

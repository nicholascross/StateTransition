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

#if canImport(PackageConfig)
import PackageConfig

let config = PackageConfig([
    "komondor": [
        // When someone has run `git commit`, first run
        // run SwiftFormat and the auto-correcter for SwiftLint
        // If there are any modifications then cancel the commit
        // so changes can be reviewed
        "pre-commit": [
            "git diff --cached --name-only | xargs git diff | md5 > .pre_format_hash",
            "swift run swiftformat .",
            "swift run swiftlint autocorrect --path StateTransition/",
            "git diff --cached --name-only | xargs git diff | md5 > .post_format_hash",
            "diff .pre_format_hash .post_format_hash > /dev/null || { echo \"Staged files modified during commit\" ; rm .pre_format_hash ; rm .post_format_hash ; exit 1; }",
            "rm .pre_format_hash ; rm .post_format_hash",
        ],
    ],
    ])
#endif


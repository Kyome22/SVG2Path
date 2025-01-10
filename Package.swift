// swift-tools-version: 6.0

import PackageDescription

let swiftSettings: [SwiftSetting] = [
    .enableUpcomingFeature("ExistentialAny"),
]

let package = Package(
    name: "SVG2Path",
    platforms: [
        .macOS(.v11),
        .iOS(.v15)
    ],
    products: [
        .library(
            name: "SVG2Path",
            targets: ["SVG2Path"]
        )
    ],
    targets: [
        .target(
            name: "SVG2Path",
            swiftSettings: swiftSettings
        ),
        .testTarget(
            name: "SVG2PathTests",
            dependencies: ["SVG2Path"],
            swiftSettings: swiftSettings
        )
    ]
)

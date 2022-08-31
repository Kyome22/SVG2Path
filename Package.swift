// swift-tools-version: 5.6

import PackageDescription

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
        .target(name: "SVG2Path"),
        .testTarget(
            name: "SVG2PathTests",
            dependencies: ["SVG2Path"]
        )
    ]
)

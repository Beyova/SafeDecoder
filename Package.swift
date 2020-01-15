// swift-tools-version:5.1

import PackageDescription

let package = Package(
    name: "SafeDecoder",
    platforms: [.iOS(.v10), .macOS(.v10_12), .tvOS(.v10)],
    products: [
        .library(
            name: "SafeDecoder",
            type: .static,
            targets: ["SafeDecoder"]),
    ],
    dependencies: [
    ],
    targets: [
        .target(
            name: "SafeDecoder",
            dependencies: []),
        .testTarget(
            name: "SafeDecoderTests",
            dependencies: ["SafeDecoder"]),
    ]
)

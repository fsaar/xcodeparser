// swift-tools-version:4.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "xcodeparser",
    dependencies: [
    ],
    targets: [
        
        .target(
            name: "xcodeparser",
            dependencies: ["xcodeparserCore"],
            path: "Sources/xcodeparser"
        ),
        .target(
            name: "xcodeparserCore",
            dependencies: [],
            path: "Sources/xcodeparserCore"
        ),
        .testTarget(
            name: "xcodeparserTests",
            dependencies: ["xcodeparserCore"],
            path: "Tests"
        )
    ]
)

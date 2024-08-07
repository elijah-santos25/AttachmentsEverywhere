// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "AttachmentsEverywhere",
    platforms: [.macOS(.v15), .iOS(.v18)],
    products: [
        .library(
            name: "AttachmentsEverywhere",
            targets: ["AttachmentsEverywhere"]),
    ],
    targets: [
        .target(
            name: "AttachmentsEverywhere",
            resources: [.process("Resources/GlassMaterial.usda")]
        ),
    ]
)

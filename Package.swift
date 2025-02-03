// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "AvatyeAdCash",
    platforms: [
        .iOS(.v11)
    ],
    products: [
        .library(
            name: "AvatyeAdCash",
            targets: ["AdPopcornSSP", "AvatyeAdCashTarget"]
        ),
    ],
    dependencies: [],
    targets: [
        .binaryTarget(
            name: "AdPopcornSSP",
            url: "https://github.com/IGAWorksDev/AdPopcornSDK/raw/refs/heads/master/AdPopcornSSP/02-ios-sdk/AdPopcornSSP_v2.9.1in.zip",
            checksum: "a7203577976fab1cd1dafcf5f8d20c3fcc163848c9c057f9a92cf78d0ea91915"
        ),
        .binaryTarget(
            name: "AvatyeAdCashTarget",
            path: "./AdCashFramework.xcframework"
        )
    ]
)

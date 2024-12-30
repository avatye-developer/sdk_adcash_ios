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
            url: "https://github.com/IGAWorksDev/AdPopcornSDK/raw/refs/heads/master/AdPopcornSSP/02-ios-sdk/AdPopcornSSP_v2.9.0in.zip",
            checksum: "7597828427595a7e8f9503939383895e6021f6eb5853f1efea71e9400d78bc5e"
        ),
        .binaryTarget(
            name: "AvatyeAdCashTarget",
            path: "./AdCashFramework.xcframework"
        )
    ]
)

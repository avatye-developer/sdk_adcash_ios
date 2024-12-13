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
            url: "https://github.com/IGAWorksDev/AdPopcornSDK/raw/refs/heads/master/AdPopcornSSP/02-ios-sdk/AdPopcornSSP_v2.8.5in.zip",
            checksum: "635e001c4075b9b3e128aac5bee3fdf25ce6c39c353498a5e7b6ef8559da9603"
        ),
        .binaryTarget(
            name: "AvatyeAdCashTarget",
            path: "./AdCashFramework.xcframework"
        )
    ]
)

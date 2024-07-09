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
            url: "https://github.com/IGAWorksDev/AdPopcornSDK/raw/master/AdPopcornSSP/02-ios-sdk/AdPopcornSSP_v2.7.2in.zip",
            checksum: "eb94c945b1a6897d5158b67d55dc5a37e46731423bf8c37391ae6c7e59ba6469"
        ),
        .binaryTarget(
            name: "AvatyeAdCashTarget",
            path: "./AvatyeAdCash.xcframework"
        )
    ]
)

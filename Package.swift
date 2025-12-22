// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "AvatyeAdCash",
    platforms: [
        .iOS(.v12)
    ],
    products: [
        .library(
            name: "AvatyeAdCash",
            targets: ["AvatyeAdCashTarget"]
        ),
    ],
    dependencies: [
        .package(
            url: "https://github.com/IGAWorksDev/ap-ssp-sdk-ios-spm-objc",
            .upToNextMinor(from: "2.11.1")
        )
    ],
    targets: [
        .binaryTarget(
            name: "AvatyeAdCashTarget",
            path: "./AdCashFramework.xcframework"
        )
    ]
)

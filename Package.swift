// swift-tools-version:6.1
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
            .upToNextMinor(from: "2.10.2")
        )
    ],
    targets: [
        .binaryTarget(
            name: "AvatyeAdCashTarget",
            path: "./AdCashFramework.xcframework"
        )
    ]
)

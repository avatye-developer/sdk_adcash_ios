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
    dependencies: [
        .package(name: "AdPopcornSSP",
                 url: "https://github.com/IGAWorksDev/AdPopcornSSP-iOS",
                 Version(2,6,5)..<Version(2,7,2)
                )
    ],
    targets: [
        .target(
            name: "AdpopcornSSP",
            dependencies: [
                .product(name: "AdPopcornSSP", package: "AdPopcornSSP"),
            ],
        ),
        .binaryTarget(
            name: "AvatyeAdCashTarget",
            path: "./AvatyeAdCash.xcframework"
        )
    ]
)

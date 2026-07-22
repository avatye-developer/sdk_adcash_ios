// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "AvatyeAdCash",
    platforms: [
        .iOS(.v13)
    ],
    products: [
        .library(
            name: "AvatyeAdCash",
            targets: ["AvatyeAdCashWrapper"]
        ),
    ],
    dependencies: [
        // B안: SPM에도 광고 SDK(APSSPSDK)를 의존성으로 포함해 소비앱에 함께 노출한다.
        // CocoaPods 핀과 동일하게 정확한 버전(3.2.2)으로 고정.
        .package(
            url: "https://github.com/IGAWorksDev/ap-APSSPSDK-SPM",
            exact: "3.2.2"
        )
    ],
    targets: [
        .binaryTarget(
            name: "AvatyeAdCashTarget",
            path: "./AdCashFramework.xcframework"
        ),
        // binaryTarget은 의존성을 가질 수 없으므로, wrapper 타깃이 binary와 APSSPSDK(SPM)를 함께 묶어
        // 소비앱이 AvatyeAdCash 하나만 추가해도 APSSPSDK가 링크되도록 한다.
        .target(
            name: "AvatyeAdCashWrapper",
            dependencies: [
                "AvatyeAdCashTarget",
                .product(name: "APSSPSDK", package: "ap-APSSPSDK-SPM")
            ],
            path: "./Sources/AvatyeAdCashWrapper" // SPM 요구사항을 만족시키기 위한 디렉토리(더미 소스 포함)
        )
    ]
)

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
        //
        // exact 가 아니라 범위인 이유:
        //   APSSPSDK 3.4.0 부터 미디에이션 어댑터가 네트워크별 저장소로 분리됐고, 각 어댑터가
        //   core 를 `from:` 으로 문다. 여기서 exact 로 상한을 못박으면 어댑터가 상위 core 를
        //   요구하는 순간 소비앱에서 해석이 실패한다. 하한은 CocoaPods 핀과 같게 유지한다.
        .package(
            url: "https://github.com/IGAWorksDev/ap-APSSPSDK-SPM",
            .upToNextMajor(from: "3.4.0")
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

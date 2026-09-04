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
        // 핀 정책: 하한은 실제 빌드에 링크한 버전, 상한은 마이너(= 패치까지만 자동 수신).
        // CocoaPods 의 `~> 3.4.1` 과 같은 해집합이며 양 채널을 항상 같은 값으로 맞춘다.
        //
        // exact 를 쓰지 않는 이유:
        //   ① 3.4.0 부터 미디에이션 어댑터가 네트워크별 저장소로 분리됐고 각 어댑터가 core 를
        //      `from:` 으로 문다. exact 로 상한을 못박으면 어댑터가 상위 core 를 요구하는 순간
        //      소비앱에서 해석이 실패한다.
        //   ② 호스트 앱이 다른 SDK 를 통해 APSSP 를 함께 받는 구성이 있어, 양쪽이 exact 면
        //      패치 버전 차이만으로 해석이 깨진다.
        //
        // 메이저까지 열지 않는 이유: 검증하지 않은 마이너 업그레이드가 조용히 들어오는 것을 막는다.
        .package(
            url: "https://github.com/IGAWorksDev/ap-APSSPSDK-SPM",
            .upToNextMinor(from: "3.4.1")
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

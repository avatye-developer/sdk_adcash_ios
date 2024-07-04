//
//  AppAdUnitModel.swift
//  AdCashFramework
//
//  Created by 임재혁 on 5/31/24.
//

import Foundation

// MARK: - Request Model

public struct AppAdUnitInput: Codable {
    public let appID: String // 앱의 고유키
    public let placementID: String // 지면 코드

    public init(aid: String, pid: String) {
        self.appID = aid
        self.placementID = pid
    }
}

// MARK: - Respose Model

public struct PlacementModel: Codable {
    let unitID: String // 지면키
    let unitValue: String // 지면값
    let networkName: String // 지면의 제공사
    let isHouseUnit: Int // 하우스 배너 여부 / yes 일때 url 포함.
    let imageUrl: String?
    let landingUrl: String?
}

struct IgaworksModel: Codable {
    let keyName: String
    let key: String
}

public struct AppAdUnitModel: Codable {
    let placementID: String // 지면코드
    let placementName: String // 지면이름
    let igaworks: IgaworksModel
    let unitType: String // 지면의 그룹 이름
    let placements: [PlacementModel]
}

public struct AdUnitNetworkInput: Codable {
    let appID: String
}

public struct AdUnitNetwork: Codable {
    let appID: String
    let networkName: String
    let keyName: String
    let key: String
}


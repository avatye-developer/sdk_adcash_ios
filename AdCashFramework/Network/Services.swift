//
//  Services.swift
//  AdCashFramework
//
//  Created by 임재혁 on 5/31/24.
//

import UIKit

// AdUnitService
class AdUnitService: BaseService {
    var url: String
    var header: [String: String]
    var param: Encodable?
    var method: String = "GET"

    // Host가 사용할 때
    init(aPid: String) {
        AdCashLogger.debug("AdUnitService init Host")
        url = APIConstants.appTestAdUnitURL
        header = NetworkUtil.getAdCashHeader(ver: "1.0.0", auth: NetworkUtil.getAppIdSecretWrappedBasic())
        param = AppAdUnitInput(aid: AdCashData.shared.appId,
                               pid: aPid)
    }

    // developer 사용할 때
    init(appId: String, appSecretKey: String, aPid: String) {
        AdCashLogger.debug("AdUnitService init developer")
        url = APIConstants.appTestAdUnitURL
        header = NetworkUtil.getAdCashHeader(ver: "1.0.0",
                                            auth: NetworkUtil.getParamIdSecretWrappedBasic(appId: appId, appSecretKey: appSecretKey))
        param = AppAdUnitInput(aid: appId,
                               pid: aPid)
    }
}

class AdUnitNetwrokSetting: BaseService {
    var url: String
    var header: [String: String]
    var param: Encodable?
    var method: String = "GET"

    init(appId: String, appSecretKey: String) {
        url = APIConstants.adUnitNetworkSetting
        header = NetworkUtil.getAdCashHeader(ver: "1.0.0", auth: NetworkUtil.getParamIdSecretWrappedBasic(appId: appId, appSecretKey: appSecretKey))
        param = AdUnitNetworkInput(appID: appId)
    }
}

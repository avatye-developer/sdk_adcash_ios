//
//  APIConstants.swift
//  AdCashFramework
//
//  Created by 임재혁 on 5/31/24.
//

import Foundation

// build 앱
struct APIConstants {
    // MARK: - Base URL

    static var getRewardURL: String {
        // qa로 변경해야함. -> 상준님
        if let devModeValue = Bundle.main.infoDictionary?["DevMode"] as? String {
            if devModeValue == "test"{
                AdCashLogger.debug("AdCashURL return url https://api-qa.reward.avatye.com")
                return "https://api-qa.reward.avatye.com"
            }else{
                AdCashLogger.debug("AdCashURL return url https://api-\(devModeValue).reward.avatye.com")
                return "https://api-\(devModeValue).reward.avatye.com"
            }
        }else{
            AdCashLogger.debug("AdCashURL return url https://api.reward.avatye.com")
            return "https://api.reward.avatye.com"
        }
    }


    // appTestADUnitURL = "https://api-test.reward.avatye.com/advertising/appAdUnit"
    static var appTestAdUnitURL: String = getRewardURL + "/advertising/appADUnit"

    // igwarks appKey 받아오기
    static var adUnitNetworkSetting: String = getRewardURL + "/advertising/appADUnitNetworkSetting"

}

// Test 앱
//struct APIConstants {
//    // MARK: - Base URL
//
//    static var getRewardURL: String {
//        if let devModeValue = AdCashData.shared.devModeValue {
//            AdCashLogger.debug("AdCashURL return url https://api-\(devModeValue).reward.avatye.com")
//            return "https://api-\(devModeValue).reward.avatye.com"
//        }else{
//            AdCashLogger.debug("AdCashURL return url https://api.reward.avatye.com")
//            return "https://api.reward.avatye.com"
//        }
//    }
//
//
//    // appTestADUnitURL = "https://api-test.reward.avatye.com/advertising/appAdUnit"
//    static var appTestAdUnitURL: String {
//        return getRewardURL + "/advertising/appADUnit"
//    }
//    
//    // igwarks appKey 받아오기
//    static var adUnitNetworkSetting: String {
//        return getRewardURL + "/advertising/appADUnitNetworkSetting"
//    }
//    
//}

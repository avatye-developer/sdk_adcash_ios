//
//  NetworkUtil.swift
//  AdCashFramework
//
//  Created by 임재혁 on 5/31/24.
//

import Foundation

class NetworkUtil {
    
    private init() {}
    
    // Host 사용. singleton에 저장되어있는 id, key를 이용해서 header 생성.
    static func getAppIdSecretWrappedBasic() -> String {
        return "Basic " + String(format: "%@:%@", AdCashData.shared.appId, AdCashData.shared.appSecretKey).data(using: String.Encoding.utf8)!.base64EncodedString()
    }
    
    // developer 사용. 파라미터로 받는 id, key를 이용해서 header 생성.
    static func getParamIdSecretWrappedBasic(appId: String, appSecretKey: String) -> String {
        return "Basic " + String(format: "%@:%@", appId, appSecretKey).data(using: String.Encoding.utf8)!.base64EncodedString()
    }
    
    static func getAdCashHeader(ver version: String, auth authorization: String) -> [String: String] {
        let header: [String: String] = [
            "Accept-Version": version,
            "Content-Type": "application/json",
            "Authorization": authorization
        ]
        return header
    }
}



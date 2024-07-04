//
//  AdCashInit.swift
//  AdCashFramework
//
//  Created by 임재혁 on 5/31/24.
//

import AdPopcornSSP
import AdSupport
import AppTrackingTransparency

class AdCashData {
    static let shared = AdCashData()
    
    var appId: String!
    var appSecretKey : String!
    var settingKey: Bool = false
    
    var devModeValue: String?
    
    private init(){
        if let devModeValue = Bundle.main.infoDictionary?["DevMode"] as? String {
            self.devModeValue = devModeValue
        }else{
            self.devModeValue = nil
        }
    }
}

@objcMembers
public class AdCashInit: NSObject{
    @objc
    public static func setting(appId: String, appSecretKey: String, logLevel: LogLevel = .info){
        AdCashLogger.logLevel = logLevel
        
        AdCashData.shared.appId = appId
        AdCashData.shared.appSecretKey = appSecretKey
        
        settingAdPopcornAppKey(appId: appId, appSecretKey: appSecretKey)
    }
    
    @objc
    public static func avatyeSetting(logLevel: LogLevel = .info) {
        AdCashLogger.logLevel = logLevel
    }
    
    public static func devModeChange(value: String? = nil){
        AdCashData.shared.devModeValue = value
    }

    static func settingAdPopcornAppKey(appId: String, appSecretKey: String) {
        if !AdCashData.shared.settingKey || AdCashData.shared.appId != appId{
            AdCashLogger.debug("AdCashInit > settingAdPopcornAppKey : with appId=\(appId)")
            AdUnitNetwrokSetting(appId: appId, appSecretKey: appSecretKey).serverAction(type: [AdUnitNetwork].self) { result in
                AdCashLogger.debug("AdCashInit > settingAdPopcornAppKey : result=\(result)")
                switch result {
                case .success(let data):
                    if let data = data as? [AdUnitNetwork] {
                        if !data.isEmpty {
                            AdPopcornSSP.setLogLevel(AdPopcornSSPLogTrace)
                            AdPopcornSSP.initializeSDK(data[0].key)
                            AdCashData.shared.settingKey = true
                            AdCashLogger.debug("AdCashInit > settingAdPopcornAppKey : settingAdPopcornKey(\(data[0].key))")
                        } else {
                            AdCashLogger.debug("adCash Init Not exist key")
                        }
                    }
                case .pathErr(let error):
                    AdCashLogger.debug("adCash Init path error \(error)")
                case .serverErr:
                    AdCashLogger.debug("adCash Init server Error")
                case .networkFail:
                    AdCashLogger.debug("adCash Init netwrokFail Error")
                case .unRecognizedError:
                    AdCashLogger.debug("adCash Init unRecognized Error")
                }
            }
        }
    }

    // IDFA 요청 팝업창 띄우기
    @objc
    public static func trackSetting() {
        AdCashLogger.debug("TrackSetting")
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            if #available(iOS 14, *) {
                ATTrackingManager.requestTrackingAuthorization { status in
                    switch status {
                    case .authorized:
                        AdCashLogger.debug("IDFA \(ASIdentifierManager.shared().advertisingIdentifier.uuidString)")
                    case .notDetermined:
                        AdCashLogger.debug("IDFA 요청 팝업을 띄운 적이 없음.")
                    case .restricted:
                        AdCashLogger.debug("IDFA 제한됨") // 사용자의 연령이 낮거나, 모르거나, 교육모드 등의 이유
                    case .denied:
                        AdCashLogger.debug("IDFA 거절됨.")
                    @unknown default:
                        AdCashLogger.debug("Unknown")
                    }
                }
            }
        }
    }
    
}

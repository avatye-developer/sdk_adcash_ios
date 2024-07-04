//
//  NativeAdLoader.swift
//  AvatyeAdCash
//
//  Created by 임재혁 on 2023/08/09.
//

import UIKit
import AdPopcornSSP
#if canImport(GoogleMobileAds)
import GoogleMobileAds
#endif

// MARK: - Delegate Tool
@objc
public protocol NativeAdLoaderDelegate: AnyObject{
    func onNativeLoaded(_ apid: String, adView: UIView)
    func onNativeFailed(_ apid: String, error: AdCashErrorModel)
    func onNativeClicked(_ apid: String)
}

@objc
public class AdCashDefault: AdPopcornSSPNativeAd{ }

@objcMembers
public class NativeAdLoader: NSObject{
    // MARK: - Properties
    let rootViewController: UIViewController!
    let placementId: String!
    
    //init 시점
    var appKey: String!
    var adUnitPlacement: [PlacementModel]!
    
    var adPopcornSSPNativeAd: AdPopcornSSPNativeAd!
    
    var config: Bool = false
    var appId: String?
    var appSecretKey: String?
    
    public var delegate: NativeAdLoaderDelegate?
    
    public init(rootVC: UIViewController, placementId: String, nativeAd: AdCashDefault){
        self.rootViewController = rootVC
        self.placementId = placementId
        self.adPopcornSSPNativeAd = nativeAd
    }
    
    // MARK: - Developer Config
    @discardableResult
    public func setConfig(appId: String, appSecretKey: String) -> Self{
        self.config = true
        self.appId = appId
        self.appSecretKey = appSecretKey
        
        AdCashInit.settingAdPopcornAppKey(appId: appId, appSecretKey: appSecretKey)
        
        return self
    }
    

    public func requestAd(){
        if rootViewController == nil || placementId == nil {
            self.delegate?.onNativeFailed(self.placementId, error: AdCashError.INVALID_PARAMETER.error)
            return
        }
        
        if config, let appId = self.appId, let appSecretKey = self.appSecretKey {
            AdCashLogger.debug("developer type")
            AdUnitService(appId: appId, appSecretKey: appSecretKey, aPid: self.placementId).serverAction(type: AppAdUnitModel.self) { response in
                self.setServiceCompletion(response: response)
            }
        }else{
            AdCashLogger.debug("host type")
            AdUnitService(aPid: self.placementId).serverAction(type: AppAdUnitModel.self) { response in
                self.setServiceCompletion(response: response)
            }
        }
        
    }
    
    private func setNativeView(){
        if let placement = self.adUnitPlacement.first{
            if let unitId = placement.unitID as? String{
                let containsNative = unitId.contains("Native")
                if containsNative{
                    self.adPopcornSSPNativeAd.setPlacementInfoWithAppKey(self.appKey, placementId: placement.unitValue, viewController: self.rootViewController)
                    
                    self.adPopcornSSPNativeAd.delegate = self
                    DispatchQueue.main.async {
                        self.adPopcornSSPNativeAd.loadRequest()
                    }
                }else{
                    self.delegate?.onNativeFailed(self.placementId, error: AdCashError.NOT_LOADED.error)
                    return
                }
            }
        }
    }
    
    private func setServiceCompletion(response: NetworkResult<Any>){
        switch response{
        case .success(let data):
            guard let data = data as? AppAdUnitModel else{
                self.delegate?.onNativeFailed(self.placementId, error: AdCashError.NOT_LOADED.error)
                return
            }
            self.appKey = data.igaworks.key
            self.adUnitPlacement = data.placements
            self.setNativeView()
        case .pathErr(let error):
            do {
                if let jsonData = String(describing: error).data(using: .utf8){
                    let decoder = JSONDecoder()
                    let serverErrorModel = try decoder.decode(ServerErrorModel.self, from: jsonData)
                    switch serverErrorModel.code{
                    case "err_cannot_find_mediation":
                        // APID KEY 에러
                        self.delegate?.onNativeFailed(self.placementId, error: AdCashError.INVALID_APID_KEY.error)
                    default:
                        // pathErr 그 외...
                        self.delegate?.onNativeFailed(self.placementId, error: AdCashError.EXCEPTION_KNOWN.error)
                    }
                }else{
                    // json 데이터 변환 실패
                    self.delegate?.onNativeFailed(self.placementId, error: AdCashError.EXCEPTION_UNKNOWN.error)
                }
            } catch {
                // serverErrormodel 파싱 실패
                self.delegate?.onNativeFailed(self.placementId, error: AdCashError.EXCEPTION_UNKNOWN.error)
            }
        case .serverErr:
            // avatye server 통신 에러
            self.delegate?.onNativeFailed(self.placementId, error: AdCashError.SERVER_TIMEOUT.error)
        case .networkFail:
            // 기기 네트워크 문제
            self.delegate?.onNativeFailed(self.placementId, error: AdCashError.SERVER_TIMEOUT.error)
        case .unRecognizedError:
            // 서버 통신 data 형식에 파싱이 불가능.
            self.delegate?.onNativeFailed(self.placementId, error: AdCashError.EXCEPTION_UNKNOWN.error)
        }
    }
    
    
}

// GAM
extension NativeAdLoader {
    public func setGAMNativeAd(xibNamed: String){
        #if canImport(GoogleMobileAds)
        if let gamNativeAdView = Bundle.main.loadNibNamed(xibNamed, owner: nil, options: nil)?.first as? GADNativeAdView{
            let apGAMNativeAdRenderer = APGAMNativeAdRenderer()
            apGAMNativeAdRenderer.gamNativeAdView = gamNativeAdView
            adPopcornSSPNativeAd.setGAMRenderer(apGAMNativeAdRenderer, superView: gamNativeAdView)
        }
        #else
        AdCashLogger.error("NativeAdLoader > GAM(GoogleMobileAds) Ads module not included")
        #endif
    }

    public func setNAMNativeAd(xibNamed: String){
        #if canImport(GFPSDK)
        if let namNativeAdView = Bundle.main.loadNibNamed(xibNamed, owner: nil, options: nil)?.first as? GFPNativeSimpleAdView{
            namNativeAdView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: 150)
            let apNAMNativeAdRenderer = APNAMNativeAdRenderer()
            apNAMNativeAdRenderer.namNativeSimpleAdView = namNativeAdView
            adPopcornSSPNativeAd.setNAMRenderer(apNAMNativeAdRenderer, superView: namNativeAdView)
        }
        #else
        AdCashLogger.error("NativeAdLoader > NAM(GFPSDK) Ads module not included")
        #endif
    }
    
    public func setNativeAd(adPopAdapter: AdPopAdapter){
        let apNativeAdRenderer = APSSPNativeAdRenderer.init()
        apNativeAdRenderer.apSSPNativeAdView = adPopAdapter
        apNativeAdRenderer.titleLabel = adPopAdapter.adCashTitleView
        apNativeAdRenderer.descLabel = adPopAdapter.adCashDescView
        apNativeAdRenderer.mainImageView = adPopAdapter.adCashMainImageView
        apNativeAdRenderer.iconImageView = adPopAdapter.adCashIconImageView
        adPopcornSSPNativeAd.setApSSPRenderer(apNativeAdRenderer, superView: adPopAdapter)
    }
}





extension NativeAdLoader :APSSPNativeAdDelegate{
    public func apsspNativeAdClicked(_ nativeAd: AdPopcornSSPNativeAd!) {
        self.delegate?.onNativeClicked(self.placementId)
    }
    
    public func apsspNativeAdImpression(_ nativeAd: AdPopcornSSPNativeAd!) {
        AdCashLogger.debug("AdPopcorn Native open")
    }
    
    public func apsspNativeAdLoadSuccess(_ nativeAd: AdPopcornSSPNativeAd!) {
        self.delegate?.onNativeLoaded(self.placementId, adView: nativeAd)
    }
    
    public func apsspNativeAdLoadFail(_ nativeAd: AdPopcornSSPNativeAd!, error: AdPopcornSSPError!) {
        var adCashError: AdCashError
        
        switch error.code{
            // 일반에러
        case 200: adCashError = .EXCEPTION_KNOWN
            // 잘못된 파라미터
        case 1000: adCashError = .INVALID_PARAMETER
            // 알려지지 않은 서버 에러
        case 9999: adCashError = .EXCEPTION_UNKNOWN
            // 잘못된 앱 키 or 잘못된 플레이스먼트 아이디
        case 2000, 2030: adCashError = .INVALID_APID_KEY
            // 광고 없음
        case 2100: adCashError = .NOT_EXSITS_APID_CAMPAIGN
            // 외부 네트워크 정보 로드 실패
        case 2200: adCashError = .NOT_LOADED
            // 네이티브 설정 초기화 오류
        case 3200: adCashError = .EXCEPTION_UNKNOWN
            // 서버 타임 아웃
        case 5000: adCashError = .SERVER_TIMEOUT
            // 네트워크 광고 로드의 실패
        case 5001, 5002: adCashError = .NOT_EXISTS_AD
        default: adCashError = .EXCEPTION_KNOWN
        }
        
        self.delegate?.onNativeFailed(self.placementId, error: adCashError.error)
    }
}

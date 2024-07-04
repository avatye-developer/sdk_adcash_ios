//
//  InterstitialAdLoader.swift
//  SdkAdLibrary
//
//  Created by 임재혁 on 2023/04/09.
//

import UIKit
import AdPopcornSSP

// MARK: - Delegate Tool
@objc
public protocol InterstitialAdDelegate: NSObjectProtocol{
    func onInterstitalLoaded(_ apid: String)
    func onInterstitalOpened(_ apid: String)
    func onInterstitalClosed(_ apid: String, isCompleted: Bool)
    func onInterstitalFailed(_ apid: String, error: AdCashErrorModel)
    func onInterstitalClicked(_ apid: String)
}

// MARK: - Interstitial Ad Loader
@objc(AVAInterstitialAdLoader)
public class InterstitialAdLoader: NSObject{
    // MARK: - Properties
    var interNativeView: InterstitialAdModule?
    var interstitialView: AdPopcornSSPInterstitialAd?
    var interstitialVideoView: AdPopcornSSPInterstitialVideoAd?
    var rewardVideoView: AdPopcornSSPRewardVideoAd?
    
    var rootViewController: UIViewController! = nil
    
    // init 시점에서 등록
    var placementId: String
    
    // Server 통신으로 얻을 수 있는 정보들.
    var appKey: String!
    var adUnitPlacement: [PlacementModel]!
    
    var completed: Bool = false
    
    // Developer가 사용
    var config: Bool = false
    var appId: String?
    var appSecretKey: String?
    
    @objc public var delegate: InterstitialAdDelegate?
    
    // MARK: - init
    @objc
    public init(placementId: String, rootViewController: UIViewController){
        self.placementId = placementId
        self.rootViewController = rootViewController
    }
    
    // MARK: - Developer Config
    @discardableResult
    @objc public func setConfig(appId: String, appSecretKey: String) -> Self{
        self.config = true
        self.appId = appId
        self.appSecretKey = appSecretKey
        
        AdCashInit.settingAdPopcornAppKey(appId: appId, appSecretKey: appSecretKey)
        
        return self
    }
    
    // MARK: - request AD
    @objc
    public func requestAd(){
        if config, let appId = self.appId, let appSecretKey = self.appSecretKey {
            AdCashLogger.debug("developer type")
            AdUnitService(appId: appId, appSecretKey: appSecretKey, aPid: self.placementId).serverAction(type: AppAdUnitModel.self) { response in
                self.setServiceCompletion(response: response)
            }
        } else {
            AdUnitService(aPid: self.placementId).serverAction(type: AppAdUnitModel.self) { response in
                self.setServiceCompletion(response: response)
            }
        }
    }
    
    private func setServiceCompletion(response: NetworkResult<Any>){
        switch response{
        case .success(let data):
            guard let data = data as? AppAdUnitModel else {
                // 통신은 성공 했으나 해당 Model로 파싱이 실패했을 때.
                self.delegate?.onInterstitalFailed(self.placementId, error: AdCashError.NOT_LOADED.error)
                return
            }
            // 최종 success
            self.appKey = data.igaworks.key
            self.adUnitPlacement = data.placements
            self.setInterAdLoad()
        case .pathErr(let err):
            do {
                if let jsonData = String(describing: err).data(using: .utf8){
                    let decoder = JSONDecoder()
                    let serverErrorModel = try decoder.decode(ServerErrorModel.self, from: jsonData)
                    switch serverErrorModel.code{
                    case "err_cannot_find_mediation":
                        // APID KEY 에러
                        self.delegate?.onInterstitalFailed(self.placementId, error: AdCashError.INVALID_APID_KEY.error)
                    default:
                        // pathErr 그 외...
                        self.delegate?.onInterstitalFailed(self.placementId, error: AdCashError.EXCEPTION_KNOWN.error)
                    }
                }else{
                    // json 데이터 변환 실패
                    self.delegate?.onInterstitalFailed(self.placementId, error: AdCashError.EXCEPTION_UNKNOWN.error)
                }
            } catch {
                // serverErrormodel 파싱 실패
                self.delegate?.onInterstitalFailed(self.placementId, error: AdCashError.EXCEPTION_UNKNOWN.error)
            }
        case .serverErr:
            // avatye server 통신 에러
            self.delegate?.onInterstitalFailed(self.placementId, error: AdCashError.SERVER_TIMEOUT.error)
        case .networkFail:
            // 기기 네트워크 문제
            self.delegate?.onInterstitalFailed(self.placementId, error: AdCashError.SERVER_TIMEOUT.error)
        case .unRecognizedError:
            // 서버 통신 data 형식에 파싱이 불가능.
            self.delegate?.onInterstitalFailed(self.placementId, error: AdCashError.EXCEPTION_UNKNOWN.error)
        }
    }
    
    // MARK: - Loader switch
    // 서버 통신 후 나온 type 별로 나눠서 광고 세팅 후 Load
    private func setInterAdLoad(){
        if let placement = self.adUnitPlacement.first{
            switch placement.unitID{
            case "Interstitial":
                DispatchQueue.main.async {
                    self.interstitialView = AdPopcornSSPInterstitialAd.init(key: self.appKey, placementId: placement.unitValue, viewController: self.rootViewController)
                    
                    self.interstitialView?.delegate = self
                
                    self.interstitialView?.loadRequest()
                }
            case "InterstitialVideo":
                DispatchQueue.main.async {
                    self.interstitialVideoView = AdPopcornSSPInterstitialVideoAd.init(key: self.appKey, placementId: placement.unitValue, viewController: self.rootViewController)
                    
                    self.interstitialVideoView?.delegate = self
                
                
                    self.interstitialVideoView?.loadRequest()
                }
            case "InterstitialRewardVideo":
                DispatchQueue.main.async {
                    self.rewardVideoView = AdPopcornSSPRewardVideoAd.init(key: self.appKey, placementId: placement.unitValue, viewController: self.rootViewController)
                
                    self.rewardVideoView?.delegate = self
                
                    self.rewardVideoView?.loadRequest()
                }
            case "InterstitialBox":
                DispatchQueue.main.async {
                AdCashLogger.debug("Inter ad Box")
                    self.interNativeView = InterstitialAdModule(appKey: self.appKey, pid: placement.unitValue, interType: .INTERSTITIAL_BOX)
                
                    self.interNativeView?.delegate = self
                
                    self.interNativeView?.requestAd()
                }
            case "InterstitialHouse":
                DispatchQueue.main.async {
                    if let imageUrl = placement.imageUrl,
                       let landUrl = placement.landingUrl{
                        self.interNativeView = InterstitialAdModule(imgUrl: imageUrl, landUrl: landUrl, interType: .INTERSTITIAL_HOUSE)
                        
                        self.interNativeView?.delegate = self
                        
                        self.interNativeView?.requestAd()
                    }
                }
            case "InterstitialNative":
                DispatchQueue.main.async {
                    self.interNativeView = InterstitialAdModule(appKey: self.appKey, pid: placement.unitValue, interType: .INTERSTITIAL_NATIVE)
                    
                    self.interNativeView?.delegate = self
                    
                    self.interNativeView?.requestAd()
                }
            default:
                AdCashLogger.error("Inter Ad Setting Error")
            }
        }
    }
}


// MARK: - Interstitial AD Delegate
extension InterstitialAdLoader: APSSPInterstitialAdDelegate{
    
    public func apsspInterstitialAdClosed(_ interstitialAd: AdPopcornSSPInterstitialAd!) {
        self.delegate?.onInterstitalClosed(self.placementId, isCompleted: true)
    }
    public func apsspInterstitialAdClicked(_ interstitialAd: AdPopcornSSPInterstitialAd!) {
        self.delegate?.onInterstitalClicked(self.placementId)
    }
    public func apsspInterstitialAdLoadSuccess(_ interstitialAd: AdPopcornSSPInterstitialAd!) {
        AdCashLogger.debug("apsspInterstitialAdLoader Success")
        interstitialAd.present(from: self.rootViewController)
        self.delegate?.onInterstitalLoaded(self.placementId)
    }
    public func apsspInterstitialAdShowSuccess(_ interstitialAd: AdPopcornSSPInterstitialAd!) {
        self.delegate?.onInterstitalOpened(self.placementId)
    }
    public func apsspInterstitialAdLoadFail(_ interstitialAd: AdPopcornSSPInterstitialAd!, error: AdPopcornSSPError!) {
        AdCashLogger.debug("apsspInterstitialAdLoader faile \(error)")
        // 지면 목록의 남은 갯수가 1보다 큰 경우에만 다음 광고 로딩.
        // 1인 경우는 마지막 광고이므로 에러 반환.
        if self.adUnitPlacement.count > 1 {
            self.adUnitPlacement.removeFirst()
            setInterAdLoad()
        } else {
            errorHandler(error: error)
        }
    }
    public func apsspInterstitialAdShowFail(_ interstitialAd: AdPopcornSSPInterstitialAd!, error: AdPopcornSSPError!) {
        self.delegate?.onInterstitalFailed(self.placementId, error: AdCashError.FAIL_OPEN.error)
    }
    
}


// MARK: - InterstitialVide AD Delegate
extension InterstitialAdLoader: APSSPInterstitialVideoAdDelegate{
    public func apsspInterstitialVideoAdClosed(_ interstitialVideoAd: AdPopcornSSPInterstitialVideoAd!) {
        self.delegate?.onInterstitalClosed(self.placementId, isCompleted: true)
    }
    
    public func apsspInterstitialVideoAdShowFail(_ interstitialVideoAd: AdPopcornSSPInterstitialVideoAd!) {
        self.delegate?.onInterstitalFailed(self.placementId, error: AdCashError.FAIL_OPEN.error)
    }
    
    public func apsspInterstitialVideoAdLoadSuccess(_ interstitialVideoAd: AdPopcornSSPInterstitialVideoAd!) {
        AdCashLogger.debug("apsspInterstitialvideoAdLoader Success")
        interstitialVideoAd.present(from: self.rootViewController)
        self.delegate?.onInterstitalLoaded(self.placementId)
    }
    
    public func apsspInterstitialVideoAdShowSuccess(_ interstitialVideoAd: AdPopcornSSPInterstitialVideoAd!) {
        self.delegate?.onInterstitalOpened(self.placementId)
    }
    
    public func apsspInterstitialVideoAdLoadFail(_ interstitialVideoAd: AdPopcornSSPInterstitialVideoAd!, error: AdPopcornSSPError!) {
        AdCashLogger.debug("apsspInterstitialvideoAdLoader fail")
        // 지면 목록의 남은 갯수가 1보다 큰 경우에만 다음 광고 로딩.
        // 1인 경우는 마지막 광고이므로 에러 반환.
        if self.adUnitPlacement.count > 1 {
            self.adUnitPlacement.removeFirst()
            setInterAdLoad()
        } else {
            errorHandler(error: error)
        }
    }
    
}

// MARK: - RewardVideo AD Delegate
extension InterstitialAdLoader: APSSPRewardVideoAdDelegate{
    public func apsspRewardVideoAdClosed(_ rewardVideoAd: AdPopcornSSPRewardVideoAd!) {
        self.delegate?.onInterstitalClosed(self.placementId, isCompleted: self.completed)
    }
    
    public func apsspRewardVideoAdShowFail(_ rewardVideoAd: AdPopcornSSPRewardVideoAd!) {
        self.delegate?.onInterstitalFailed(self.placementId, error: AdCashError.FAIL_OPEN.error)
    }
    
    public func apsspRewardVideoAdLoadSuccess(_ rewardVideoAd: AdPopcornSSPRewardVideoAd!) {
        AdCashLogger.debug("apssprewardVideoAdLoader Success")
        rewardVideoAd.present(from: self.rootViewController)
        self.delegate?.onInterstitalLoaded(self.placementId)
    }
    
    public func apsspRewardVideoAdShowSuccess(_ rewardVideoAd: AdPopcornSSPRewardVideoAd!) {
        self.delegate?.onInterstitalOpened(self.placementId)
    }
    
    public func apsspRewardVideoAdLoadFail(_ rewardVideoAd: AdPopcornSSPRewardVideoAd!, error: AdPopcornSSPError!) {
        AdCashLogger.debug("apssprewardVideoAdLoader Success")
        // 지면 목록의 남은 갯수가 1보다 큰 경우에만 다음 광고 로딩.
        // 1인 경우는 마지막 광고이므로 에러 반환.
        if self.adUnitPlacement.count > 1 {
            self.adUnitPlacement.removeFirst()
            setInterAdLoad()
        } else {
            errorHandler(error: error)
        }
    }
    
    public func apsspRewardVideoAdPlayCompleted(_ rewardVideoAd: AdPopcornSSPRewardVideoAd!, adNetworkNo: Int, completed: Bool) {
        self.completed = completed
    }
    
}


extension InterstitialAdLoader: InterAdModuleDelegate{
    public func onInterModuleOpen() {
        AdCashLogger.debug("Inter Ad Module Open")
    }
    
    public func onInterModuleLoad() {
        interNativeView?.present(from: self.rootViewController)
        self.delegate?.onInterstitalLoaded(self.placementId)
    }
    
    public func onInterModuleFail(error: AdCashErrorModel) {
        // 지면 목록의 남은 갯수가 1보다 큰 경우에만 다음 광고 로딩.
        // 1인 경우는 마지막 광고이므로 에러 반환.
        if self.adUnitPlacement.count > 1 {
            self.adUnitPlacement.removeFirst()
            setInterAdLoad()
        } else {
            self.delegate?.onInterstitalFailed(self.placementId, error: error)
        }
    }
    
    public func onInterModuleClosed() {
        self.interNativeView?.dismiss(animated: true, completion: nil)
        self.delegate?.onInterstitalClosed(self.placementId, isCompleted: true)
    }
    
    public func onInterModuleClick() {
        AdCashLogger.debug("Inter Ad Module Click")
    }
}

extension InterstitialAdLoader {
    private func errorHandler(error: AdPopcornSSPError!){
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
        
        self.delegate?.onInterstitalFailed(self.placementId, error: adCashError.error)
    }
}

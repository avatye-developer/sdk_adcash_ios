//
//  BannerAdLoader.swift
//  AdCashFramework
//
//  Created by 임재혁 on 5/31/24.
//

import AdPopcornSSP
import UIKit

// MARK: - Delegate Tool
@objc
public protocol BannerAdLoaderDelegate: NSObjectProtocol {
    func onBannerLoaded(_ apid: String, adView: UIView, size: CGSize)
    func onBannerFailed(_ apid: String, error: AdCashErrorModel)
    func onBannerClicked(_ apid: String)
    func onBannerRemoved(_ apid: String)
}

// Loader 방식의 Banner Ad
@objc(AVABannerAdLoader)
public class BannerAdLoader: NSObject {
    // MARK: - Properties
    // Type 별로 불러오는 AdLoader
    var bannerView: AdPopAdView?
    var houseBannerView: HouseAdView?
    var nativeBannerView: NativeAdView?
    
    // init 시점에서 등록.
    weak var rootViewController: UIViewController?
    let placementId: String!
    let adSize: BannerAdSize!
    var adView: UIView! = nil
    
    // Server 통신으로만 얻을 수 있는 정보들.
    var adType: String!
    var appKey: String!
    var adUnitPlacement: [PlacementModel]!
    
    // Developer가 사용.
    var config: Bool = false
    var appId: String?
    var appSecretKey: String?
    
    @objc public weak var delegate: BannerAdLoaderDelegate?
    
    // MARK: - initialize
    @objc
    public init(rootVC: UIViewController, placementId: String, size: BannerAdSize, adView: UIView? = nil) {
        self.rootViewController = rootVC
        self.placementId = placementId
        self.adSize = size
        self.adView = adView
    }
    
    // MARK: - Developer Config

    @discardableResult
    @objc public func setConfig(appId: String, appSecretKey: String) -> Self {
        self.config = true
        self.appId = appId
        self.appSecretKey = appSecretKey
        
        AdCashInit.settingAdPopcornAppKey(appId: appId, appSecretKey: appSecretKey)
        
        return self
    }
    
    // MARK: - Public Func 사용자가 사용하는 함수.
    @objc
    public func requestAd() {
        // init 시점에서 등록되는 값이 없을 시
        if self.rootViewController == nil || self.placementId == nil || self.adSize == nil {
            self.delegate?.onBannerFailed(self.placementId, error: AdCashError.INVALID_PARAMETER.error)
            return
        }
        
        // config를 사용했을 때 > Avatye PointHome 또는 Avatye에서 사용할 때
        if self.config, let appId = self.appId, let appSecretKey = self.appSecretKey {
            AdCashLogger.debug("Developer Type")
            AdUnitService(appId: appId, appSecretKey: appSecretKey, aPid: self.placementId).serverAction(type: AppAdUnitModel.self) { response in
                self.setServiceCompletion(response: response)
            }
        } else {
            // Host 사용시 > init 시점에서 appId / appSecretKey를 추가했을 때
            AdCashLogger.debug("Host Type")
            AdUnitService(aPid: self.placementId).serverAction(type: AppAdUnitModel.self) { response in
                self.setServiceCompletion(response: response)
            }
        }
    }
    
    @objc
    public func removeAd() {
        switch self.adType {
        case "House":
            if let houseBannerView = self.houseBannerView{
                houseBannerView.onDestory()
                self.houseBannerView = nil
                AdCashLogger.debug("houseBannerView Remove Success")
            }else{
                AdCashLogger.debug("houseBannerView nil / Remove fail")
            }
        case "Native":
            if let nativeBannerView = self.nativeBannerView{
                nativeBannerView.onDestroy()
                self.nativeBannerView = nil
                AdCashLogger.debug("nativeBannerView Remove Success")
            }else{
                AdCashLogger.debug("nativeBannerView nil / Remove fail")
            }
        case "adPop":
            if let bannerView = self.bannerView {
                bannerView.onDestroy()
                self.bannerView = nil
                AdCashLogger.debug("adPopBannerView Remove Success")
            }else{
                AdCashLogger.debug("adPopBannerView nil / Remove fail")
            }
        default:
            AdCashLogger.debug("not type")
        }
        
        self.delegate?.onBannerRemoved(self.placementId)
    }
    
    // MARK: - Setting

    private func setBannerView() {
        // 서버 통신 후 가장 첫번째에 있는 unitPlacement 정보.
        // 남아있는 지면이 없는 경우 마지막 에러 반환(처음부터 0인 경우, 서버에서 에러 발생)
        if let placement = self.adUnitPlacement.first {
            AdCashLogger.debug("setBannerView placement \(placement)")
            // placemet.unitID -> "Banner320X50".
            if let unitId = placement.unitID as? String {
                // "Banner320X50"에서 숫자만 filter > "32050"
                let size = unitId.filter { $0.isNumber }
                // 사용자가 init 시점에서 작성한 size와 서버통신을 통해 얻은 size 가 같을때 실행.
                if size == self.adSize.numSize || self.adSize == .DYNAMIC {
                    var serverAdSize: BannerAdSize! = nil
                    
                    switch size {
                    case "32050":
                        serverAdSize = .W320XH50
                    case "320100":
                        serverAdSize = .W320XH100
                    case "300250":
                        serverAdSize = .W300XH250
                    default:
                        serverAdSize = .DYNAMIC
                    }
                    
                    // House 또는 Native 의 type
                    if let range = unitId.range(of: "House|Native|Nam", options: .regularExpression) {
                        let extractedString = unitId[range]
                        switch extractedString {
                        case "House":
                            self.adType = "House"
                            if let imageUrl = placement.imageUrl,
                               let landUrl = placement.landingUrl
                            {
                                DispatchQueue.main.async {
                                    self.houseBannerView = HouseAdView(imgUrl: imageUrl, landUrl: landUrl, size: serverAdSize)
                                    self.houseBannerView?.delegate = self
                                
                                    self.houseBannerView?.loadRequestAd()
                                }
                            }
                        case "Native":
                            self.adType = "Native"
                            DispatchQueue.main.async {
                                if let rootViewController = self.rootViewController{
                                    self.nativeBannerView = NativeAdView(rootVC: rootViewController, key: self.appKey, pid: placement.unitValue, size: serverAdSize)
                                    self.nativeBannerView?.delegate = self
                                    
                                    self.nativeBannerView?.loadRequestAd()
                                }
                            }
                            
                        case "Nam":
                            if self.adSize == .DYNAMIC {
                                self.adType = "adPop"
                                DispatchQueue.main.async {
                                    if let rootVC = self.rootViewController{
                                        self.bannerView = AdPopAdView(rootVC: rootVC, appKey: self.appKey, placementId: placement.unitValue, size: serverAdSize, adView: self.adView)
                                        self.bannerView?.delegate = self
                                        
                                        self.bannerView?.loadRequestView()
                                    }
                                }
                            } else {
                                // 사용자가 설정한 size와 list Size가 다름
                                if self.adUnitPlacement.count > 1 {
                                    self.adUnitPlacement.removeFirst()
                                    self.setBannerView()
                                }
                            }
                            
                        default:
                            // range of : 에 추가를 했으나 case에 추가를 안했을 때.
                            self.delegate?.onBannerFailed(self.placementId, error: AdCashError.EXCEPTION_UNKNOWN.error)
                        }
                    } else {
                        AdCashLogger.debug("adPopcorn Banner setting")
                        self.adType = "adPop"
                        // adPopcornSSP 타입.
                        DispatchQueue.main.async {
                            if let rootVC = self.rootViewController{
                                self.bannerView = AdPopAdView(rootVC: rootVC, appKey: self.appKey, placementId: placement.unitValue, size: serverAdSize, adView: self.adView)
                                self.bannerView?.delegate = self
                                
                                self.bannerView?.loadRequestView()
                            }
                        }
                    }
                } else {
                    // 사용자가 init 시점에서 작성한 size와 서버통신을 통해 얻은 Size가 다름.
                    // Error. 발생.
                    AdCashLogger.debug("setBannerView NotEqual \(size) \(self.adSize.numSize)")
                    if self.adUnitPlacement.count > 1 {
                        self.adUnitPlacement.removeFirst()
                        self.setBannerView()
                    }
                }
            }
        }
    }
    
    // Service complement
    private func setServiceCompletion(response: NetworkResult<Any>) {
        switch response {
        case .success(let data):
            guard let data = data as? AppAdUnitModel else {
                self.delegate?.onBannerFailed(self.placementId, error: AdCashError.NOT_LOADED.error)
                return
            }
            AdCashLogger.debug("data \(data.placementID)")
            self.appKey = data.igaworks.key
            self.adUnitPlacement = data.placements
            self.setBannerView()
        case .pathErr(let error):
            do {
                if let jsonData = String(describing: error).data(using: .utf8) {
                    let decoder = JSONDecoder()
                    let serverErrorModel = try decoder.decode(ServerErrorModel.self, from: jsonData)
                    switch serverErrorModel.code {
                    case "err_cannot_find_mediation":
                        // APID KEY 에러
                        self.delegate?.onBannerFailed(self.placementId, error: AdCashError.INVALID_APID_KEY.error)
                    default:
                        // pathErr 그 외...
                        self.delegate?.onBannerFailed(self.placementId, error: AdCashError.EXCEPTION_KNOWN.error)
                    }
                } else {
                    // json 데이터 변환 실패
                    self.delegate?.onBannerFailed(self.placementId, error: AdCashError.EXCEPTION_UNKNOWN.error)
                }
            } catch {
                // serverErrormodel 파싱 실패
                self.delegate?.onBannerFailed(self.placementId, error: AdCashError.EXCEPTION_UNKNOWN.error)
            }
        case .serverErr:
            // avatye server 통신 에러
            self.delegate?.onBannerFailed(self.placementId, error: AdCashError.SERVER_TIMEOUT.error)
        case .networkFail:
            // 기기 네트워크 문제
            self.delegate?.onBannerFailed(self.placementId, error: AdCashError.SERVER_TIMEOUT.error)
        case .unRecognizedError:
            // 서버 통신 data 형식에 파싱이 불가능.
            self.delegate?.onBannerFailed(self.placementId, error: AdCashError.EXCEPTION_UNKNOWN.error)
        }
    }
}

// MARK: - Delegate
extension BannerAdLoader: AdViewDelegate {
    // Loader 방식에서는 Delegate에 Ad를 넘겨줍니다.
    public func onViewLoad(adView: UIView) {
        self.delegate?.onBannerLoaded(self.placementId, adView: adView, size: adView.frame.size)
    }
    
    public func onViewFailed(error: AdCashErrorModel) {
        AdCashLogger.debug("error \(error)")
        if self.adUnitPlacement.count > 1 {
            self.adUnitPlacement.removeFirst()
            self.setBannerView()
        }else{
            self.delegate?.onBannerFailed(self.placementId, error: error)
        }
    }
    
    public func onViewClicked() {
        self.delegate?.onBannerClicked(self.placementId)
    }
}


//
//  AdPopBannerView.swift
//  SdkAdLibrary
//
//  Created by 임재혁 on 2023/04/13.
//

import UIKit
import AdPopcornSSP

class AdPopAdView: NSObject{
    // MARK: - properties
    
    var adView: UIView! = nil
    var bannerView: AdPopcornSSPBannerView!
    
    var rootViewController: UIViewController
    var appKey: String
    var placementId: String
    var adSize: BannerAdSize
    
    var delegate: AdViewDelegate?
    
    // MARK: - Init
    public init(rootVC: UIViewController, appKey: String, placementId: String, size: BannerAdSize, adView: UIView? = nil){
        AdCashLogger.debug("adpopadview init")
        self.rootViewController = rootVC
        self.appKey = appKey
        self.placementId = placementId
        self.adSize = size
        if adView == nil{
            self.adView = UIView()
        }else{
            self.adView = adView
        }
        super.init()
    
        self.setAdPopBannerView()
    }
    
    // MARK: - Setting
    private func setAdPopBannerView(){
        
        switch self.adSize{
        case .W300XH250:
            self.bannerView = AdPopcornSSPBannerView(bannerViewSize: SSPBannerViewSize300x250,
                                                     origin: CGPoint(x: 0.0, y: 0.0),
                                                     appKey: self.appKey, placementId: self.placementId,
                                                     view: self.adView, rootViewController: self.rootViewController)
        case .W320XH100:
            self.bannerView = AdPopcornSSPBannerView(bannerViewSize: SSPBannerViewSize320x100,
                                                     origin: CGPoint(x: 0.0, y: 0.0),
                                                     appKey: self.appKey, placementId: self.placementId,
                                                     view: self.adView, rootViewController: self.rootViewController)
        case .W320XH50:
            self.bannerView = AdPopcornSSPBannerView(bannerViewSize: SSPBannerViewSize320x50,
                                                     origin: CGPoint(x: 0.0, y: 0.0),
                                                     appKey: self.appKey,
                                                     placementId: self.placementId,
                                                     view: self.adView,
                                                     rootViewController: self.rootViewController)
        case .DYNAMIC:
            self.bannerView = AdPopcornSSPBannerView(bannerViewSize: SSPBannerViewSizeAdaptive,
                                                     origin: CGPoint(x: 0.0, y: 0.0),
                                                     appKey: self.appKey,
                                                     placementId: self.placementId,
                                                     view: self.adView,
                                                     rootViewController: self.rootViewController)
        }
        
        self.bannerView.delegate = self
        self.bannerView.adRefreshRate = -1
        self.bannerView.setAutoBgColor(false)
        AdCashLogger.debug("AdPopAdView setAdPopBannerView \(self.adSize)")
    }
    
    public func loadRequestView(){
        
        DispatchQueue.main.async {
            AdCashLogger.debug("AdPopAdView loadRequest")
            self.bannerView.loadRequest()
        }
    }
    
    public func onPause(){
        self.bannerView.stopAd()
    }
    
    public func onDestroy(){
        self.bannerView.removeFromSuperview()
        
        bannerView.stopAd()
        
        self.adView = nil
        self.bannerView = nil
    }
    
}

extension AdPopAdView: APSSPBannerViewDelegate{
    public func apsspBannerViewClicked(_ bannerView: AdPopcornSSPBannerView!) {
        self.delegate?.onViewClicked()
    }
    
    public func apsspBannerViewLoadSuccess(_ bannerView: AdPopcornSSPBannerView!) {
        AdCashLogger.debug("apsspBannerViewLoadSuccess")
        self.delegate?.onViewLoad(adView: bannerView)
    }
    
    public func apsspBannerViewLoadFail(_ bannerView: AdPopcornSSPBannerView!, error: AdPopcornSSPError!) {
        AdCashLogger.debug("apsspBannerViewLoadFail \(error)")
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
        
        self.delegate?.onViewFailed(error: adCashError.error)
    }
}

//
//  InterNativeView.swift
//  SdkAdLibrary
//
//  Created by 임재혁 on 2023/04/12.
//

import UIKit
import AdPopcornSSP

class NativeAdView: NSObject{
    // MARK: - Properties
    var rootViewController: UIViewController
    var appKey: String
    var placementId: String
    var adSize: BannerAdSize
    
    var apSSPNativeAdRenderer: APSSPNativeAdRenderer!
    
    #if canImport(GoogleMobileAds)
    var gamNativeAdView: GADNativeAdView!
    #endif
    #if canImport(GFPSDK)
    var namNativeSimpleAdView: GFPNativeSimpleAdView!
    #endif
    
    private lazy var adPopcornSSPNativeAd: AdPopcornSSPNativeAd = {
        let AdView = AdPopcornSSPNativeAd(frame: .zero, key: self.appKey, placementId: self.placementId, viewController: self.rootViewController)
        AdView!.delegate = self
        AdView!.translatesAutoresizingMaskIntoConstraints = false
        return AdView!
    }()
    
    private lazy var apSSPNativeAdView: UIView = {
        let adView = UIView()
        adView.translatesAutoresizingMaskIntoConstraints = false
        return adView
    }()
    private lazy var apSSPMainImageView: UIImageView = {
        let mainImage = UIImageView()
        mainImage.translatesAutoresizingMaskIntoConstraints = false
        return mainImage
    }()
    
    private lazy var apSSPIconImageView: UIImageView = {
        let iconImage = UIImageView()
        iconImage.translatesAutoresizingMaskIntoConstraints = false
        return iconImage
    }()

    private lazy var apSSPTitleView: UILabel = {
        let titleView = UILabel()
        titleView.translatesAutoresizingMaskIntoConstraints = false
        titleView.font = UIFont.systemFont(ofSize: 30)
        titleView.font = UIFont.boldSystemFont(ofSize: UIFont.labelFontSize)
        return titleView
    }()

    private lazy var apSSPDescView: UILabel = {
       let descView = UILabel()
        descView.translatesAutoresizingMaskIntoConstraints = false
        descView.font = UIFont.systemFont(ofSize: 15)
        return descView
    }()
    
    var interNativeMainView: UIView! = nil
    
    weak var delegate: AdViewDelegate?

    public init(rootVC: UIViewController, key: String, pid: String, size: BannerAdSize) {
        self.rootViewController = rootVC
        self.appKey = key
        self.placementId = pid
        self.adSize = size
        
        super.init()
        self.interNativeMainView = UIView(frame: CGRect(origin: CGPoint(x: 0, y: 0), size: size.size))
        self.setNativeAd()
    }
    

    private func setNativeAd(){
        adPopcornSSPNativeAd.setPlacementInfoWithAppKey(self.appKey, placementId: self.placementId, viewController: self.rootViewController)
        adPopcornSSPNativeAd.delegate = self
        
        apSSPNativeAdRenderer = APSSPNativeAdRenderer.init()
        apSSPNativeAdRenderer.apSSPNativeAdView = apSSPNativeAdView
        apSSPNativeAdRenderer.titleLabel = apSSPTitleView
        apSSPNativeAdRenderer.descLabel = apSSPDescView
        apSSPNativeAdRenderer.mainImageView = apSSPMainImageView
        apSSPNativeAdRenderer.iconImageView = apSSPIconImageView
        adPopcornSSPNativeAd.setApSSPRenderer(apSSPNativeAdRenderer, superView: apSSPNativeAdView)
        
        switch self.adSize{
        case .W300XH250:
            #if canImport(GoogleMobileAds)
            gamNativeAdView = Bundle.main.loadNibNamed("MGAMNativeAdView", owner: nil, options: nil)?.first as? GADNativeAdView
            #endif
        case .W320XH100:
            #if canImport(GoogleMobileAds)
            gamNativeAdView = Bundle.main.loadNibNamed("BGAMNativeAdView", owner: nil, options: nil)?.first as? GADNativeAdView
            #endif
        case .W320XH50:
            #if canImport(GoogleMobileAds)
            gamNativeAdView = Bundle.main.loadNibNamed("SGAMNativeAdView", owner: nil, options: nil)?.first as? GADNativeAdView
            #endif
        case .DYNAMIC:
            #if canImport(GFPSDK)
            namNativeSimpleAdView = Bundle.main.loadNibNamed("GFPNativeSimpleAdView", owner: nil, options: nil)?.first as? GFPNativeSimpleAdView
            namNativeSimpleAdView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: 80)
            #endif
        }
        
        #if canImport(GoogleMobileAds)
        let apGAMNativeAdRenderer = APGAMNativeAdRenderer()
        apGAMNativeAdRenderer.gamNativeAdView = gamNativeAdView
        adPopcornSSPNativeAd.setGAMRenderer(apGAMNativeAdRenderer, superView: gamNativeAdView)
        #endif
        
        #if canImport(GFPSDK)
        let apNAMNativeAdRenderer = APNAMNativeAdRenderer()
        apNAMNativeAdRenderer.namNativeSimpleAdView = namNativeSimpleAdView
        adPopcornSSPNativeAd.setNAMRenderer(apNAMNativeAdRenderer, superView: namNativeSimpleAdView)
        #endif
        
    }
    
    private func setBannerSizeConstraint(){
           NSLayoutConstraint.activate([
               adPopcornSSPNativeAd.topAnchor.constraint(equalTo: self.interNativeMainView.topAnchor),
               adPopcornSSPNativeAd.trailingAnchor.constraint(equalTo: self.interNativeMainView.trailingAnchor),
               adPopcornSSPNativeAd.leadingAnchor.constraint(equalTo: self.interNativeMainView.leadingAnchor),
               adPopcornSSPNativeAd.bottomAnchor.constraint(equalTo: self.interNativeMainView.bottomAnchor),
               apSSPNativeAdView.topAnchor.constraint(equalTo: self.adPopcornSSPNativeAd.topAnchor),
               apSSPNativeAdView.trailingAnchor.constraint(equalTo: self.adPopcornSSPNativeAd.trailingAnchor),
               apSSPNativeAdView.leadingAnchor.constraint(equalTo: self.adPopcornSSPNativeAd.leadingAnchor),
               apSSPNativeAdView.bottomAnchor.constraint(equalTo: self.adPopcornSSPNativeAd.bottomAnchor),
           ])
       }
    
    private func setStriptBannerConstraint(){
        NSLayoutConstraint.activate([
            apSSPIconImageView.widthAnchor.constraint(equalToConstant: 40),
            apSSPIconImageView.heightAnchor.constraint(equalToConstant: 40),
            apSSPIconImageView.topAnchor.constraint(equalTo: self.apSSPNativeAdView.topAnchor, constant: 5),
            apSSPIconImageView.leadingAnchor.constraint(equalTo: self.apSSPNativeAdView.leadingAnchor, constant: 10),
            apSSPTitleView.topAnchor.constraint(equalTo: self.apSSPNativeAdView.topAnchor, constant: 5),
            apSSPTitleView.leadingAnchor.constraint(equalTo: self.apSSPIconImageView.trailingAnchor, constant: 15),
            apSSPTitleView.widthAnchor.constraint(equalToConstant: 200),
            apSSPDescView.topAnchor.constraint(equalTo: self.apSSPTitleView.bottomAnchor, constant: 5),
            apSSPDescView.leadingAnchor.constraint(equalTo: self.apSSPIconImageView.trailingAnchor, constant: 15),
            apSSPDescView.widthAnchor.constraint(equalToConstant: 200)
        ])
    }
    
    private func setImageConstraint(){
        NSLayoutConstraint.activate([
            apSSPMainImageView.topAnchor.constraint(equalTo: self.apSSPIconImageView.bottomAnchor, constant: 10),
            apSSPMainImageView.trailingAnchor.constraint(equalTo: self.apSSPNativeAdView.trailingAnchor, constant: -10),
            apSSPMainImageView.leadingAnchor.constraint(equalTo: self.apSSPNativeAdView.leadingAnchor, constant: 10),
            apSSPMainImageView.bottomAnchor.constraint(equalTo: self.apSSPNativeAdView.bottomAnchor, constant: -10)
        ])
    }
    
    
    public func loadRequestAd(){
        self.interNativeMainView.addSubview(adPopcornSSPNativeAd)
        self.adPopcornSSPNativeAd.addSubview(apSSPNativeAdView)
        switch self.adSize{
        case .W300XH250:
            self.apSSPNativeAdView.addSubview(apSSPIconImageView)
            self.apSSPNativeAdView.addSubview(apSSPTitleView)
            self.apSSPNativeAdView.addSubview(apSSPDescView)
            self.apSSPNativeAdView.addSubview(apSSPMainImageView)
            setBannerSizeConstraint()
            setStriptBannerConstraint()
            setImageConstraint()
        case .W320XH100:
            self.apSSPNativeAdView.addSubview(apSSPIconImageView)
            self.apSSPNativeAdView.addSubview(apSSPTitleView)
            self.apSSPNativeAdView.addSubview(apSSPDescView)
            self.apSSPNativeAdView.addSubview(apSSPMainImageView)
            setBannerSizeConstraint()
            setStriptBannerConstraint()
            setImageConstraint()
        case .W320XH50:
            self.apSSPNativeAdView.addSubview(apSSPIconImageView)
            self.apSSPNativeAdView.addSubview(apSSPTitleView)
            self.apSSPNativeAdView.addSubview(apSSPDescView)
            setBannerSizeConstraint()
            setStriptBannerConstraint()
        case .DYNAMIC:
            self.interNativeMainView.frame.size = CGSize(width: UIScreen.main.bounds.width, height: 80)
        }
        DispatchQueue.main.async{
            self.adPopcornSSPNativeAd.loadRequest()
        }
    }
    
    public func onDestroy(){
        self.adPopcornSSPNativeAd.stop()
        self.interNativeMainView.removeFromSuperview()
    }
}

extension NativeAdView :APSSPNativeAdDelegate{
    public func apsspNativeAdClicked(_ nativeAd: AdPopcornSSPNativeAd!) {
        self.delegate?.onViewClicked()
    }
    
    // 네이티브 광고 화면 노출
    public func apsspNativeAdImpression(_ nativeAd: AdPopcornSSPNativeAd!) {
        AdCashLogger.debug("AdPopcorn Native open")
    }
    
    public func apsspNativeAdLoadSuccess(_ nativeAd: AdPopcornSSPNativeAd!) {
        self.delegate?.onViewLoad(adView: self.interNativeMainView)
        AdCashLogger.debug("nativeAd size \(nativeAd.frame.size) ")
        AdCashLogger.debug("interNativeAd size \(self.interNativeMainView.frame.size) ")
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
        
        self.delegate?.onViewFailed(error: adCashError.error)
    }
}

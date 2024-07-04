//
//  BannerAdLoader.swift
//  SdkAdLibrary
//
//  Created by 임재혁 on 2023/04/06.
//

import UIKit
import AdPopcornSSP

// MARK: - Delegate Tool
@objc
public protocol BannerAdWidgetDelegate: AnyObject{
    func onBannerLoaded(_ apid: String)
    func onBannerFailed(_ apid: String, error: AdCashErrorModel)
    func onBannerClicked(_ apid: String)
    func onBannerRemoved(_ apid: String)
}

// MARK: - Widget 방식의 Banner Ad
@objc(AVABannerAdView)
public class BannerAdView: UIView{
    // MARK: - Properties
    // AdLoader
    var adLoader: BannerAdLoader! = nil
    
    // init 시점에서 등록.
    var point: CGPoint!
    var placementId: String!
    var adSize: BannerAdSize!
    
    // Developer가 사용.
    var config: Bool = false
    var appId: String?
    var appSecretKey: String?
    
    @objc public weak var delegate: BannerAdWidgetDelegate?
    
    // MARK: - initialize
    @objc
    public override init(frame: CGRect){
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    // MARK: - Developer Config
    @discardableResult
    @objc public func setConfig(appId: String, appSecretKey: String) -> Self{
        self.config = true
        self.appId = appId
        self.appSecretKey = appSecretKey
        
        return self
    }
    
    // MARK: - Public Func
    @objc
    public func setBannerAd(rootVC: UIViewController, placementId: String, size: BannerAdSize){
        self.placementId = placementId
        self.adSize = size
        
        adLoader = BannerAdLoader(rootVC: rootVC, placementId: placementId, size: size, adView: self)
        
        // Avatye PointHome || Avatye 에서 사용.
        if config, let appId = self.appId , let appSecretKey = self.appSecretKey{
            AdCashLogger.debug("Developer")
            adLoader.setConfig(appId: appId, appSecretKey: appSecretKey)
        }
        
        adLoader.delegate = self
    }
    
    @objc
    public func requestAd(){
        if  placementId == nil || adSize == nil {
            self.delegate?.onBannerFailed(self.placementId, error: AdCashError.INVALID_PARAMETER.error)
            return
        }
        
        adLoader.requestAd()
    }
    
    @objc
    public func removeAd(){
        if let adLoader = self.adLoader{
            adLoader.removeAd()
        }
    }
    
    @objc
    public func releaseAd(){
        if let adLoader = self.adLoader{
            adLoader.removeAd()
            self.adLoader = nil
        }
    }
    
}

extension BannerAdView: BannerAdLoaderDelegate{
    public func onBannerLoaded(_ apid: String, adView: UIView, size: CGSize) {
        
        let centerPoint: CGPoint = CGPoint(x: (self.frame.width / 2) + self.frame.origin.x , y: (self.frame.height / 2) + self.frame.origin.y)

        self.frame = CGRect(x: centerPoint.x - (size.width / 2), y: centerPoint.y - (size.height / 2), width: size.width, height: size.height)
        
        self.addSubview(adView)
        
        self.translatesAutoresizingMaskIntoConstraints = false
        adView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            self.widthAnchor.constraint(equalToConstant: size.width),
            self.heightAnchor.constraint(equalToConstant: size.height),
            
            adView.widthAnchor.constraint(equalToConstant: size.width),
            adView.heightAnchor.constraint(equalToConstant: size.height),
            adView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            adView.centerYAnchor.constraint(equalTo: self.centerYAnchor)
        ])
        
        self.delegate?.onBannerLoaded(apid)
    }
    
    public func onBannerFailed(_ apid: String, error: AdCashErrorModel) {
        self.delegate?.onBannerFailed(apid, error: error)
    }
    
    public func onBannerClicked(_ apid: String) {
        self.delegate?.onBannerClicked(apid)
    }
    
    public func onBannerRemoved(_ apid: String) {
        self.delegate?.onBannerRemoved(apid)
    }
}

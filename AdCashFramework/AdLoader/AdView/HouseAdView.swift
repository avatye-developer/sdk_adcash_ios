//
//  HouseBannerView.swift
//  SdkAdLibrary
//
//  Created by 임재혁 on 2023/04/12.
//

import UIKit
import AdPopcornSSP

public protocol AdViewDelegate: AnyObject{
    func onViewLoad(adView: UIView)
    func onViewFailed(error: AdCashErrorModel)
    func onViewClicked()
}

class HouseAdView{
    //MARK: - properties
    var houseView: UIImageView! = nil
    var imgUrl: String
    var landUrl: String
    var sizeType: String
    
    weak var delegate: AdViewDelegate?
    
    public init(imgUrl: String, landUrl: String, size: BannerAdSize) {
        self.imgUrl = imgUrl
        self.landUrl = landUrl
        self.sizeType = size.numSize
        self.houseView = UIImageView(frame: CGRect(origin: CGPoint(x: 0, y: 0), size: size.size))
    }
    
    // 전면광고 320480 크기
    public init(imgUrl: String, landUrl: String) {
        self.imgUrl = imgUrl
        self.landUrl = landUrl
        self.sizeType = "320480"
        self.houseView = UIImageView(frame: CGRect(x: 0, y: 0, width: 320, height: 480))
    }

    private func setHouseBanner(){
        let url = URL(string: self.imgUrl)
        let session = URLSession.shared
        let task = session.dataTask(with: url!){ (data, response, error) in
            if error != nil{
                self.delegate?.onViewFailed(error: AdCashError.EXCEPTION_KNOWN.error)
                return
            }
            
            DispatchQueue.main.async {
                if let image = UIImage(data: data!){
                    self.houseView.image = image
                    self.delegate?.onViewLoad(adView: self.houseView)
                }
            }
        }
        task.resume()
        
        houseView.isUserInteractionEnabled = true
        houseView.contentMode = .scaleAspectFit
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(openLandUrl))
        houseView.addGestureRecognizer(tapGestureRecognizer)
    }
    
    @objc func openLandUrl(){
        if let url = URL(string: self.landUrl){
            UIApplication.shared.open(url)
        }
        self.delegate?.onViewClicked()
    }
    
    public func loadRequestAd(){
        
        self.setHouseBanner()
    }
    
    public func onDestory(){
        self.houseView.removeFromSuperview()
    }
}

//
//  InterstitialAdModule.swift
//  SdkAdLibrary
//
//  Created by 임재혁 on 2023/04/11.
//

import UIKit

public protocol InterAdModuleDelegate: AnyObject{
    func onInterModuleLoad()
    func onInterModuleFail(error: AdCashErrorModel)
    func onInterModuleClosed()
    func onInterModuleClick()
    func onInterModuleOpen()
}

class InterstitialAdModule: UIViewController{
    // MARK: - info
    var interAdType: CustomInterAdType!
    var appKey: String?
    var placementId: String?
    var imageUrl: String?
    var landingUrl: String?
    
    private lazy var adView: UIView = {
       let view = UIView(frame: CGRect(x: 0, y: 0, width: 300, height: 250))
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    // properties
    var interBoxView: AdPopAdView?
    var interHouseView: HouseAdView?
    var interNativeView: NativeAdView?
    
    weak var delegate: InterAdModuleDelegate?
    
    private lazy var dimmingView: UIView = {
       let dimmingView = UIView()
        dimmingView.backgroundColor = .white
        dimmingView.translatesAutoresizingMaskIntoConstraints = false
        return dimmingView
    }()
    
    private lazy var closeBtn: UIButton = {
       let closeBtn = UIButton()
        closeBtn.setTitle("", for: .normal)
        closeBtn.setImage(CommonUtil.getImageFromBundle(named: "icon_close"), for: .normal)
        closeBtn.setTitleColor(.black, for: .normal)
        closeBtn.tintColor = .black
        closeBtn.translatesAutoresizingMaskIntoConstraints = false
        closeBtn.addTarget(self, action: #selector(closeBtnAction), for: .touchUpInside)
        return closeBtn
    }()
    
    // MARK: - Init
    public init(appKey: String, pid: String, interType: CustomInterAdType){
        self.appKey = appKey
        self.placementId = pid
        self.interAdType = interType
        super.init(nibName: nil, bundle: nil)
        
        setInterView()
    }
    
    public init(imgUrl: String, landUrl: String, interType: CustomInterAdType){
        self.imageUrl = imgUrl
        self.landingUrl = landUrl
        self.interAdType = interType
        super.init(nibName: nil, bundle: nil)
        
        setInterView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
    }
    
    
    // MARK: - Setting
    private func setInterView(){
        switch self.interAdType{
        case .INTERSTITIAL_BOX:
            interBoxView = AdPopAdView(rootVC: self, appKey: self.appKey!, placementId: self.placementId!, size: .W300XH250)
            
            interBoxView?.delegate = self
        case .INTERSTITIAL_HOUSE:
            interHouseView = HouseAdView(imgUrl: self.imageUrl!, landUrl: self.landingUrl!)
            
            interHouseView?.delegate = self
        case .INTERSTITIAL_NATIVE:
            interNativeView = NativeAdView(rootVC: self, key: self.appKey!, pid: self.placementId!, size: .W300XH250)
            
            interNativeView?.delegate = self
        case .none:
            AdCashLogger.error("SetInterView Non Type")
        }
    }
    
    private func setConstraint(){
        NSLayoutConstraint.activate([
            dimmingView.topAnchor.constraint(equalTo: self.view.topAnchor),
            dimmingView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            dimmingView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            dimmingView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
        ])
    }
    
    private func setViewConstraint(width: CGFloat, height: CGFloat){
        NSLayoutConstraint.activate([
            self.adView.centerXAnchor.constraint(equalTo: self.dimmingView.centerXAnchor),
            self.adView.centerYAnchor.constraint(equalTo: self.dimmingView.centerYAnchor, constant: 40),
            self.adView.widthAnchor.constraint(equalToConstant: width),
            self.adView.heightAnchor.constraint(equalToConstant: height)
        ])
    }
    
    @objc private func closeBtnAction(){
        self.delegate?.onInterModuleClosed()
    }
    
    public func requestAd(){
        AdCashLogger.debug("inter ad request")
        self.view.addSubview(dimmingView)
        self.dimmingView.addSubview(closeBtn)
        
        setConstraint()
        
        self.view.addSubview(self.adView)
        
        switch self.interAdType{
        case.INTERSTITIAL_BOX:
            setViewConstraint(width: 300, height: 250)
            DispatchQueue.main.async {
                self.interBoxView?.loadRequestView()
            }
            
        case .INTERSTITIAL_HOUSE:
            setViewConstraint(width: 320, height: 480)
            DispatchQueue.main.async {
                self.interHouseView?.loadRequestAd()
            }
            
        case .INTERSTITIAL_NATIVE:
            setViewConstraint(width: 300, height: 250)
            DispatchQueue.main.async {
                self.interNativeView?.loadRequestAd()
            }
        case .none:
            AdCashLogger.error("Inter Ad Not Type")
        }
    }
    
    public func present(from presentingVC: UIViewController){
        let navController = UINavigationController(rootViewController: self)
        navController.modalPresentationStyle = .overFullScreen
        presentingVC.present(navController, animated: true, completion: nil)
        self.delegate?.onInterModuleOpen()
    }
}

extension InterstitialAdModule: AdViewDelegate{
    public func onViewLoad(adView: UIView) {
        AdCashLogger.debug("Inter Ad Module view Load")
        self.delegate?.onInterModuleLoad()
        self.adView.addSubview(adView)
        AdCashLogger.debug("Inter Ad Module adView size \(adView.frame.size)")
        self.closeBtn.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            self.closeBtn.widthAnchor.constraint(equalToConstant: 20),
            self.closeBtn.heightAnchor.constraint(equalToConstant: 20),
            self.closeBtn.bottomAnchor.constraint(equalTo: self.adView.topAnchor, constant: -20),
            self.closeBtn.trailingAnchor.constraint(equalTo: self.adView.trailingAnchor),
        ])
        AdCashLogger.debug("Inter Ad Module adView closeBtn \(self.closeBtn.frame)")
    }
    
    public func onViewFailed(error: AdCashErrorModel) {
        AdCashLogger.debug("Inter Ad Module view Load")
        self.delegate?.onInterModuleFail(error: error)
    }
    
    public func onViewClicked() {
        AdCashLogger.debug("Inter Ad Module view clicked")
        self.delegate?.onInterModuleClick()
    }
    
}

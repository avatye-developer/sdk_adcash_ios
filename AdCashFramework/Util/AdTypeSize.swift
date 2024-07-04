//
//  BannerAdSize.swift
//  SdkAdLibrary
//
//  Created by 임재혁 on 2023/04/06.
//

import Foundation

// 배너 Size
@objc
public enum BannerAdSize: Int{
    case W320XH50
    case W320XH100
    case W300XH250
    case DYNAMIC
    
    var size: CGSize{
        switch self{
        case .W300XH250:
            return CGSize(width: 300, height: 250)
        case .W320XH100:
            return CGSize(width: 320, height: 100)
        case .W320XH50:
            return CGSize(width: 320, height: 50)
        case .DYNAMIC:
            return CGSize(width: 0, height: 0)
        }
    }
    
    var numSize: String{
        switch self{
        case .W300XH250:
            return "300250"
        case .W320XH100:
            return "320100"
        case .W320XH50:
            return "32050"
        case .DYNAMIC:
            return "Dynamic"
        }
    }
}

// 사용?
public enum HouseBannerAdSize{
    case W320XH50
    case W320XH100
    case W300XH250
    case W320XH480
}

public enum InterAdType{
    case INTERSTITIAL
    case INTERSTITIAL_BOX
    case INTERSTITIAL_VIDEO
    case INTERSTITIAL_REWARD_VIDEO
    case INTERSTITIAL_HOUSE
    case INTERSTITIAL_NATIVE
}

public enum CustomInterAdType{
    case INTERSTITIAL_BOX
    case INTERSTITIAL_HOUSE
    case INTERSTITIAL_NATIVE
}


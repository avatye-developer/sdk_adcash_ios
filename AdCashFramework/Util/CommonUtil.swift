//
//  CommonUtil.swift
//  AdCashFramework
//
//  Created by 임재혁 on 5/31/24.
//

import UIKit

class CommonUtil {
    private static let BundleResource = "AvatyeAdCashResource"
    
    static func getImageFromBundle(named: String) -> UIImage? {
        let libraryBundle = Bundle(for: Self.self)
        if let resouceUrl = libraryBundle.url(forResource: BundleResource, withExtension: "bundle") {
            let resourceBundle = Bundle(url: resouceUrl)
            let originalImage = UIImage(named: named, in: resourceBundle, compatibleWith: nil)
            AdCashLogger.debug("Image(\(named)) load success from Bundle(\(String(describing: resourceBundle)))")
            
            return originalImage
        } else {
            AdCashLogger.error("resourceBundle no exists")
            let frameworkBundle = Bundle(for: CommonUtil.self)
            return UIImage(named: named, in: frameworkBundle, compatibleWith: nil)
        }
    }
}

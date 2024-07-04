//
//  AdPopAdapter.swift
//  AvatyeAdCash
//
//  Created by 임재혁 on 2023/08/16.
//

import UIKit

public class AdPopAdapter: UIView {

    var adCashIconImageView: UIImageView! = nil
    var adCashTitleView: UILabel! = nil
    var adCashDescView: UILabel! = nil
    var adCashMainImageView: UIImageView! = nil
    
    @discardableResult
    public func setIcon(_ icon: UIImageView) -> Self{
        self.adCashIconImageView = icon
        return self
    }
    
    @discardableResult
    public func setTitle(_ title: UILabel) -> Self{
        self.adCashTitleView = title
        return self
    }
    
    @discardableResult
    public func setDesc(_ desc: UILabel) -> Self{
        self.adCashDescView = desc
        return self
    }
    
    @discardableResult
    public func setMainImage(_ mainImage: UIImageView) -> Self{
        self.adCashMainImageView = mainImage
        return self
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

}

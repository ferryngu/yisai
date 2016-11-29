//
//  YSExtension.swift
//  YISAI
//
//  Created by Yufate on 15/7/1.
//  Copyright (c) 2015年 Shenzhen Jianbo Information Technology Co., Ltd. All rights reserved.
//

import Foundation

/** UIColor 转 UIImage */
extension UIImage {
    class func createImageWithColor(color: UIColor) -> UIImage {
        let rect = CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: 3)
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()
        CGContextSetFillColorWithColor(context!, color.CGColor)
        CGContextFillRect(context!, rect)
        let resp_image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return resp_image!
    }
}
extension UIColor {
    convenience init(red: Int, green: Int, blue: Int) {
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")
        
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
    }
    
    convenience init(netHex:Int) {
        self.init(red:(netHex >> 16) & 0xff, green:(netHex >> 8) & 0xff, blue:netHex & 0xff)
    }
}

/** 设置Tabbar小红点大小 */
extension UITabBar {
    
    /** 显示小红点 */
    func showBadgeOnItemIndex(index: Int) {
        
        self.removeBadgeOnItemIndex(index)
        
        let badgeView = UIView()
        badgeView.tag = 1000 + index
        badgeView.layer.cornerRadius = 5
        badgeView.backgroundColor = UIColor.redColor()
        
        let tabFrame = self.frame
        
        let percentX = (CGFloat(index) + 0.6) / 3
        let x = ceilf(Float(percentX * tabFrame.size.width))
        let y = ceilf(Float(0.1 * tabFrame.size.height))
        badgeView.frame = CGRect(x: Int(x), y: Int(y), width: 10, height: 10)
        
        self.addSubview(badgeView)
    }
    
    /** 隐藏小红点 */
    func hideBadgeOnItemIndex(index: Int) {
        
        self.removeBadgeOnItemIndex(index)
    }
    
    /** 移除小红点 */
    private func removeBadgeOnItemIndex(index: Int) {
        
        for subView in self.subviews {
            if subView.tag == 1000 + index {
                subView.removeFromSuperview()
            }
        }
    }
}

extension UIView
{
    // MARK: - left/right/top/bottom/width/height属性
    
    /// 左间距
    var left:CGFloat {
        get {
            return self.frame.origin.x
        }
        set(newValue) {
            var rect = self.frame
            rect.origin.x = newValue
            self.frame = rect
        }
    }
    
    /// 右间距
    var right:CGFloat {
        get {
            return (self.frame.origin.x + self.frame.size.width)
        }
        set(newValue) {
            var rect = self.frame
            rect.origin.x = (newValue - self.frame.size.width)
            self.frame = rect
        }
    }
    
    /// 顶端间距
    var top:CGFloat {
        get {
            return self.frame.origin.y
        }
        set(newValue) {
            var rect = self.frame
            rect.origin.y = newValue
            self.frame = rect
        }
    }
    
    /// 底端间距
    var bottom:CGFloat {
        get {
            return (self.frame.origin.y + self.frame.size.height)
        }
        set(newValue) {
            var rect = self.frame
            rect.origin.y = (newValue - self.frame.size.height)
            self.frame = rect
        }
    }
    
    /// 长度
    var width:CGFloat {
        get {
            return self.frame.size.width
        }
        set(newValue) {
            var rect = self.frame
            rect.size.width = newValue
            self.frame = rect
        }
    }
    
    /// 宽度
    var height:CGFloat {
        get {
            return self.frame.size.height
        }
        set(newValue)
        {
            var rect = self.frame
            rect.size.height = newValue
            self.frame = rect
        }
    }
}


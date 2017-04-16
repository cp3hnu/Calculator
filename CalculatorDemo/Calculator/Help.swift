//
//  Help.swift
//  CalculatorDemo
//
//  Created by CP3 on 17/4/13.
//  Copyright © 2017年 CP3. All rights reserved.
//

import Foundation
import UIKit

public extension UIColor {
    /**
     Initializes using hex value.
     
     - parameter rgbHexValue: The RGB component value whose format is 0xRRGGBB. e.g. 0xFFFFFF is white color.
     - parameter alpha: The opacity value of the color object, specified as a value from 0.0 to 1.0. Default is 1.0.
     */
    public convenience init(rgbHexValue: UInt, alpha: Float = 1.0) {
        self.init(redInt: (rgbHexValue & 0xFF0000) >> 16,
                  greenInt: (rgbHexValue & 0x00FF00) >> 8,
                  blueInt: rgbHexValue & 0x0000FF,
                  alpha: alpha)
    }
    
    /**
     Initializes using tuples.
     
     - parameter rgbTriple: The RGB component triple of which value from 0 to 255.
     - parameter alpha: The opacity value of the color object, specified as a value from 0.0 to 1.0. Default is 1.0.
     */
    public convenience init(rgbTriple: (red: UInt, green: UInt, blue: UInt), alpha: Float = 1.0) {
        self.init(redInt: rgbTriple.red,
                  greenInt: rgbTriple.green,
                  blueInt: rgbTriple.blue,
                  alpha: alpha)
    }
    
    /**
     Initializes.
     
     - parameter rgbSameValue: The RGB component value. They are same.
     - parameter alpha: The opacity value of the color object, specified as a value from 0.0 to 1.0. Default is 1.0.
     */
    public convenience init(equalRGBValue: UInt, alpha: Float = 1.0) {
        self.init(redInt: equalRGBValue,
                  greenInt: equalRGBValue,
                  blueInt: equalRGBValue,
                  alpha: alpha)
    }
    
    /**
     Initializes using RGB component value from 0 to 255.
     
     - parameter redInt: The red component of the color object, specified as a value from 0 to 255.
     - parameter greenInt: The green component of the color object, specified as a value from 0 to 255.
     - parameter blueInt: The blue component of the color object, specified as a value from 0 to 255.
     - parameter alpha: The opacity value of the color object, specified as a value from 0.0 to 1.0. Default is 1.0.
     */
    public convenience init(redInt: UInt, greenInt: UInt, blueInt: UInt, alpha: Float = 1.0) {
        self.init(red: CGFloat(redInt)/255.0,
                  green: CGFloat(greenInt)/255.0,
                  blue: CGFloat(blueInt)/255.0,
                  alpha: CGFloat(alpha))
    }
    
    
    /// iOS 默认的tint color
    static var systemTintColor: UIColor {
        return UIColor(rgbTriple: (0, 122,255))
    }
    
    /// 由颜色变换成image
    func image() -> UIImage {
        let rect = CGRect(x: 0, y: 0, width: 1, height: 1)
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()!
        
        context.setFillColor(self.cgColor)
        context.fill(rect)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image!
    }
}

public extension UIButton {
    /// 可以设置高亮时的背景色
    public func setBackgroundColor(_ color: UIColor, forUIControlState state: UIControlState) {
        self.setBackgroundImage(color.image(), for: state)
    }
}

extension UILabel {
    /// 设置字体，参数是字体(UIFont)
    func font(_ font: UIFont) -> Self {
        self.font = font
        return self
    }
    
    /// 设置字体，参数是字体大小
    func fontSize(_ size: CGFloat) -> Self {
        self.font = UIFont.systemFont(ofSize: size)
        return self
    }
    
    /// 设置文字颜色
    func textColor(_ color: UIColor) -> Self {
        self.textColor = color
        return self
    }
    
    /// 文字左对齐
    func alignLeft() -> Self {
        return self.align()
    }
    
    /// 文字居中
    func alignMiddle() -> Self {
        return self.align(.center)
    }
    
    /// 文字右对齐
    func alignRight() -> Self {
        return self.align(.right)
    }
    
    /// 设置行数
    func numberOfLines(_ number: Int) -> Self {
        self.numberOfLines = number
        return self
    }
    
    fileprivate func align(_ alignment: NSTextAlignment = .left) -> Self {
        self.textAlignment = alignment
        return self
    }
}

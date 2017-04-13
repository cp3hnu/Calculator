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
        let context = UIGraphicsGetCurrentContext()
        
        CGContextSetFillColorWithColor(context, self.CGColor)
        CGContextFillRect(context, rect)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image
    }
}

public extension UIButton {
    /// 可以设置高亮时的背景色
    public func setBackgroundColor(color: UIColor, forUIControlState state: UIControlState) {
        self.setBackgroundImage(color.image(), forState: state)
    }
}

extension UILabel {
    /// 设置字体，参数是字体(UIFont)
    func font(font: UIFont) -> Self {
        self.font = font
        return self
    }
    
    /// 设置字体，参数是字体大小
    func fontSize(size: CGFloat) -> Self {
        self.font = UIFont.systemFontOfSize(size)
        return self
    }
    
    /// 设置文字颜色
    func textColor(color: UIColor) -> Self {
        self.textColor = color
        return self
    }
    
    /// 文字左对齐
    func alignLeft() -> Self {
        return self.align()
    }
    
    /// 文字居中
    func alignMiddle() -> Self {
        return self.align(.Center)
    }
    
    /// 文字右对齐
    func alignRight() -> Self {
        return self.align(.Right)
    }
    
    /// 设置行数
    func numberOfLines(number: Int) -> Self {
        self.numberOfLines = number
        return self
    }
    
    private func align(alignment: NSTextAlignment = .Left) -> Self {
        self.textAlignment = alignment
        return self
    }
}

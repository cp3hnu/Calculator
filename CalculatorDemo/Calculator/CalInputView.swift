//
//  CalInputView.swift
//  hnup
//
//  Created by CP3 on 16/5/12.
//  Copyright © 2016年 DataYP. All rights reserved.
//

import UIKit

enum CalOperation {
    
    case Addition
    case Subtraction
    case Multiplication
    case Division
    case Equality
    case Clear
    case Completion
    case DecimalPoint
    case Digit(Int)
    
    // 操作数，由多个digit和"."组成
    case Operand(Double)
    
    var character: String {
        var _character = ""
        switch self {
        case .Addition:
            _character = "+"
        case .Subtraction:
            _character = "-"
        case .Multiplication:
            _character = "×"
        case .Division:
            _character = "÷"
        case .Equality:
            _character = "＝"
        case .DecimalPoint:
            _character = "."
        case .Digit(let digit):
            _character = String(digit)
        case .Operand(let value):
            _character = String(value)
        default:
            _character = ""
        }
        
        return _character
    }
    
    var isOperator: Bool {
        switch self {
        case .Addition, .Subtraction, .Multiplication, .Division:
            return true
        default:
            return false
        }
    }
    
    var isHighPriorityOperator: Bool {
        switch self {
        case .Multiplication, .Division:
            return true
        default:
            return false
        }
    }
    
    var isLowPriorityOperator: Bool {
        switch self {
        case .Addition, .Subtraction:
            return true
        default:
            return false
        }
    }
    
    var isUserInput: Bool {
        switch self {
        case .Digit(_), .DecimalPoint:
            return true
        default:
            return false
        }
    }
}

private let kButtonBaseTag = 100

final class CalInputView: UIView {
    
    private var array = [UIButton]()
    var userOperation: ((CalOperation) -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    
        let characters = ["←", "C", "÷", "×", "1", "2", "3", "－", "4", "5", "6", "＋", "7", "8", "9", "=", "0", "."]
        for (i, title) in characters.enumerate() {
            let button = UIButton()
            button.tag = kButtonBaseTag + i
            button.setTitleColor(UIColor(rgbHexValue: 0x666666), forState: .Normal)
            button.layer.borderWidth = 0.5
            button.layer.borderColor = UIColor(rgbHexValue: 0xEBEBEB).CGColor
            button.setTitle(title, forState: .Normal)
            button.addTarget(self, action: #selector(buttonClicked(_:)), forControlEvents: .TouchUpInside)
            self.addSubview(button)
            array.append(button)
            
            if (i >= 0 && i <= 3) || i == 7 || i == 11 {
                button.setBackgroundColor(UIColor(rgbTriple: (252, 252, 252)), forUIControlState: .Normal)
            } else if i == 15 {
                button.setBackgroundColor(UIColor.systemTintColor, forUIControlState: .Normal)
                button.setTitleColor(UIColor.whiteColor(), forState: .Normal)
            } else {
                button.setBackgroundColor(UIColor.whiteColor(), forUIControlState: .Normal)
            }
        }
    }
   
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let buttonWidth = frame.width/4
        let buttonHeight = frame.height/5
        var buttonFrame: CGRect
        for (i, button) in array.enumerate() {
            buttonFrame = CGRectMake(CGFloat(i%4) * buttonWidth, CGFloat(i/4) * buttonHeight, buttonWidth, buttonHeight)
            if i == 15 {
                buttonFrame.size.height = 2 * buttonHeight
            } else if i == 16 {
                buttonFrame.size.width = 2 * buttonWidth
            } else if i == 17 {
                buttonFrame.origin.x += buttonWidth
            }
            
            button.frame = buttonFrame
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

//MARK: - Action
private extension CalInputView {
    
    @objc func buttonClicked(button: UIButton) {
        let tag = Int(button.tag) - kButtonBaseTag
        if let closure = userOperation, let operation = operation(forTag: tag) {
            closure(operation)
        }
    }
    
    func operation(forTag tag: Int) -> CalOperation? {
        var _operation: CalOperation? = nil
        switch tag {
        case 0:
            _operation = .Completion
        case 1:
            _operation = .Clear
        case 2:
            _operation = .Division
        case 3:
            _operation = .Multiplication
        case 4...6:
            _operation = .Digit(tag - 3)
        case 7:
            _operation = .Subtraction
        case 8...10:
            _operation = .Digit(tag - 4)
        case 11:
            _operation = .Addition
        case 12...14:
            _operation = .Digit(tag - 5)
        case 15:
            _operation = .Equality
        case 16:
            _operation = .Digit(0)
        case 17:
            _operation = .DecimalPoint
        default:
            break
        }
        
        return _operation
    }
}

//
//  CalInputView.swift
//  hnup
//
//  Created by CP3 on 16/5/12.
//  Copyright © 2016年 DataYP. All rights reserved.
//

import UIKit

enum CalOperation {
    
    case addition
    case subtraction
    case multiplication
    case division
    case equality
    case clear
    case completion
    case decimalPoint
    case digit(Int)
    
    // 操作数，由多个digit和"."组成
    case operand(Double)
    
    var character: String {
        var _character = ""
        switch self {
        case .addition:
            _character = "+"
        case .subtraction:
            _character = "-"
        case .multiplication:
            _character = "×"
        case .division:
            _character = "÷"
        case .equality:
            _character = "＝"
        case .decimalPoint:
            _character = "."
        case .digit(let digit):
            _character = String(digit)
        case .operand(let value):
            _character = String(value)
        default:
            _character = ""
        }
        
        return _character
    }
    
    var isOperator: Bool {
        switch self {
        case .addition, .subtraction, .multiplication, .division:
            return true
        default:
            return false
        }
    }
    
    var isHighPriorityOperator: Bool {
        switch self {
        case .multiplication, .division:
            return true
        default:
            return false
        }
    }
    
    var isLowPriorityOperator: Bool {
        switch self {
        case .addition, .subtraction:
            return true
        default:
            return false
        }
    }
    
    var isUserInput: Bool {
        switch self {
        case .digit(_), .decimalPoint:
            return true
        default:
            return false
        }
    }
}

private let kButtonBaseTag = 100

final class CalInputView: UIView {
    
    fileprivate var array = [UIButton]()
    var userOperation: ((CalOperation) -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    
        let characters = ["←", "C", "÷", "×", "1", "2", "3", "－", "4", "5", "6", "＋", "7", "8", "9", "=", "0", "."]
        for (i, title) in characters.enumerated() {
            let button = UIButton()
            button.tag = kButtonBaseTag + i
            button.setTitleColor(UIColor(rgbHexValue: 0x666666), for: UIControlState())
            button.layer.borderWidth = 0.5
            button.layer.borderColor = UIColor(rgbHexValue: 0xEBEBEB).cgColor
            button.setTitle(title, for: UIControlState())
            button.addTarget(self, action: #selector(buttonClicked(_:)), for: .touchUpInside)
            self.addSubview(button)
            array.append(button)
            
            if (i >= 0 && i <= 3) || i == 7 || i == 11 {
                button.setBackgroundColor(UIColor(rgbTriple: (252, 252, 252)), forUIControlState: UIControlState())
            } else if i == 15 {
                button.setBackgroundColor(UIColor.systemTintColor, forUIControlState: UIControlState())
                button.setTitleColor(UIColor.white, for: UIControlState())
            } else {
                button.setBackgroundColor(UIColor.white, forUIControlState: UIControlState())
            }
        }
    }
   
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let buttonWidth = frame.width/4
        let buttonHeight = frame.height/5
        var buttonFrame: CGRect
        for (i, button) in array.enumerated() {
            buttonFrame = CGRect(x: CGFloat(i%4) * buttonWidth, y: CGFloat(i/4) * buttonHeight, width: buttonWidth, height: buttonHeight)
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
    
    @objc func buttonClicked(_ button: UIButton) {
        let tag = Int(button.tag) - kButtonBaseTag
        if let closure = userOperation, let operation = operation(forTag: tag) {
            closure(operation)
        }
    }
    
    func operation(forTag tag: Int) -> CalOperation? {
        var _operation: CalOperation? = nil
        switch tag {
        case 0:
            _operation = .completion
        case 1:
            _operation = .clear
        case 2:
            _operation = .division
        case 3:
            _operation = .multiplication
        case 4...6:
            _operation = .digit(tag - 3)
        case 7:
            _operation = .subtraction
        case 8...10:
            _operation = .digit(tag - 4)
        case 11:
            _operation = .addition
        case 12...14:
            _operation = .digit(tag - 5)
        case 15:
            _operation = .equality
        case 16:
            _operation = .digit(0)
        case 17:
            _operation = .decimalPoint
        default:
            break
        }
        
        return _operation
    }
}

//
//  CalculatorCtrlr.swift
//  hnup
//
//  Created by CP3 on 16/5/12.
//  Copyright © 2016年 DataYP. All rights reserved.
//

import UIKit

struct CalStack<Element> {
    fileprivate var elements = [Element]()
    
    mutating func push(_ element: Element) {
        elements.append(element)
        
    #if DEBUG
        print("--- push \((element as! CalOperation).character) ---")
        printArray()
    #endif
    }
    
    @discardableResult mutating func pop() -> Element? {
        let element = elements.popLast()
        
    #if DEBUG
        if let a = element {
            print("--- pop \((a as! CalOperation).character) ---")
        } else {
            print("--- pop nil ---")
        }
        printArray()
    #endif
        
        return element
    }
    
    var topItem: Element? {
        return elements.last
    }
    
    var count: Int {
        return elements.count
    }
    
    mutating func removeAll() {
        elements.removeAll()
    }
    
    var secondItem: Element? {
        if elements.count >= 2 {
            return elements[elements.count - 2]
        }
        return nil
    }
    
#if DEBUG
    func printArray() {
        print("stack: \n(")
        for op in elements {
            print("  ", (op as! CalOperation).character, ",")
        }
        print(")\n")
    }
#endif
}

public final class Calculator: UIViewController {

    fileprivate let expressionLabel = UILabel().fontSize(24).textColor(UIColor(rgbHexValue: 0x999999)).alignRight()
    fileprivate let resultLabel = UILabel().fontSize(48).textColor(UIColor(rgbHexValue: 0x333333)).alignRight()
    fileprivate let formatter = NumberFormatter()
    
    // 记录用户输入的操作
    fileprivate var stack = CalStack<CalOperation>()
    // 备份执行的操作，主要用于用户输入"+/-"之后，变换成"×／÷"
    fileprivate var backupStack = CalStack<CalOperation>()
    
    // 记录用户输入的数字和小数点
    fileprivate var userInput = ""
    // 用户输入的数值或者计算出来的结果
    fileprivate var accumulator: Double = 0.0
    // 记录表达式
    fileprivate var expression = "" {
        didSet {
            expressionLabel.text = expression
        }
    }
    // 记录前一个不会变化的表达式
    fileprivate var preExpression = ""
    // 记录用户输入的数值表达式，这个值是不断变化和修正的
    fileprivate var inputExpression = "" {
        didSet {
            expression = preExpression + inputExpression
        }
    }
    
    // 标记是否输入了等号
    fileprivate var isPreEquality = true
    // 标记是否输入了运算符
    fileprivate var isPreOperator = false
    
    /// 计算完成回调，将计算结果返回
    public var completion: ((Double) -> Void)?
    
    public init() {
        super.init(nibName: nil, bundle: nil)
        initFormatter()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initFormatter()
    }
    
    private func initFormatter() {
        formatter.numberStyle = .decimal
        formatter.alwaysShowsDecimalSeparator = false
        formatter.maximumFractionDigits = 8
        formatter.exponentSymbol = "e"
        formatter.positiveInfinitySymbol = "错误"
        formatter.negativeInfinitySymbol = "错误"
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "计算器"
        setupView()
    }
}

private extension Calculator {
    func setupView() {
        view.backgroundColor = UIColor.white
        
        let resultBoardView = { () -> UIView in
            let resultView = UIView()
            resultView.backgroundColor = UIColor.white
            expressionLabel.lineBreakMode = .byTruncatingHead
            resultLabel.text = "0"
            resultLabel.adjustsFontSizeToFitWidth = true
            resultLabel.baselineAdjustment = .alignCenters
            let space1 = UIView(), space2 = UIView(), space3 = UIView()
            
            resultView.addSubview(space1)
            resultView.addSubview(space2)
            resultView.addSubview(space3)
            resultView.addSubview(expressionLabel)
            resultView.addSubview(resultLabel)
            
            [space1, space2, space3, expressionLabel, resultLabel].forEach { view in
                view.translatesAutoresizingMaskIntoConstraints = false
            }
            
            resultView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[space1][expressionLabel(==29)][space2(==space1)][resultLabel][space3(==space1)]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["space1": space1, "space2": space2, "space3": space3, "expressionLabel": expressionLabel, "resultLabel": resultLabel]))
            resultView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[space1]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["space1": space1]))
            resultView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[space2]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["space2": space2]))
            resultView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[space3]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["space3": space3]))
            resultView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-15-[expressionLabel]-15-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["expressionLabel": expressionLabel]))
            resultView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-15-[resultLabel]-15-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["resultLabel": resultLabel]))

            return resultView
        }()
        let inputBoardView = CalInputView()
        resultBoardView.backgroundColor = UIColor.white
        
        view.addSubview(resultBoardView)
        view.addSubview(inputBoardView)
        resultBoardView.translatesAutoresizingMaskIntoConstraints = false
        inputBoardView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[topGuide][resultBoardView][inputBoardView]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["topGuide": topLayoutGuide, "resultBoardView": resultBoardView, "inputBoardView": inputBoardView]))
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[resultBoardView]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["resultBoardView": resultBoardView]))
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[inputBoardView]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["inputBoardView": inputBoardView]))
        view.addConstraint(NSLayoutConstraint(item: resultBoardView, attribute: .height, relatedBy: .equal, toItem: inputBoardView, attribute: .height, multiplier: 0.35, constant: 0))
        
        inputBoardView.userOperation = { [unowned self] operation in
            self.handleOperation(operation)
        }
    }
}

private extension Calculator {
    func handleOperation(_ operation: CalOperation) {
        // 用户点击"＝"或者"清空(C)"操作之后，清空表达式，
        if isPreEquality {
            preExpression = ""
            inputExpression = ""
            expression = ""
        }
        
        // 用户输入的不是操作符(+、－、×、÷)，清空备份栈内容
        if !operation.isOperator {
            backupStack.removeAll()
        }
        
        // 处理对应的各种操作
        switch operation {
        case .digit(let digit):
            handleDigit(digit)
        case .decimalPoint:
            handleDot()
        case .addition, .subtraction:
            handleLowOperation(operation)
        case .multiplication, .division:
            handleHighOperation(operation)
        case .equality:
            handleEquality()
        case .clear:
            handleClearOperator()
        case .completion:
            handleComplication()
        default:
            break
        }
        
        // 记录上一次的操作是不是等于操作，清空(C)相当于一个结果为0的等于操作
        switch operation {
        case .equality, .clear:
            isPreEquality = true
        default:
            isPreEquality = false
        }
        
        // 记录上一次的操作是不是操作符，如果是操作符，记录此时的表达式
        if operation.isOperator {
            isPreOperator = true
            preExpression = expression
        } else {
            isPreOperator = false
        }
    }
    
    // 处理输入数字
    func handleDigit(_ digit: Int) {
        // 一次最多输入9个数字，不包括小数点
        let hasDot = userInputHasDot()
        if userInput.characters.count >= (hasDot ? 10 : 9) {
            return
        }
        
        // 记录用户输入的操作数
        userInput += String(digit)
        accumulator = Double(userInput) ?? 0.0
        
        // 清除前导0
        if !hasDot && accumulator == 0 {
            userInput = ""
        }
        
        // 展示输入数，没有小数点时，格式化；有小数点时，直接添加
        if !hasDot {
            updateResultText(isCalculation: false)
        } else {
            resultLabel.text = (resultLabel.text ?? "") + String(digit)
            inputExpression = resultLabel.text ?? ""
        }
    }
    
    // 处理输入小数点
    func handleDot() {
        // 已经存在小数点，或者已经输入了9个数字
        if userInputHasDot() || userInput.characters.count >= 9 {
            return
        }
        
        // "."变换成"0."
        if userInput.isEmpty {
            userInput = "0."
            resultLabel.text = "0."
        } else {
            userInput += "."
            resultLabel.text = (resultLabel.text ?? "") + "."
        }
        
        accumulator = Double(userInput) ?? 0.0
        inputExpression = resultLabel.text ?? ""
    }
    
    // 处理＋、－运算
    func handleLowOperation(_ operation: CalOperation) {
        // 前一个是运算符，出栈
        if isPreOperator {
            //弹出前一个运算符
            stack.pop()
            // 表达式删除前一个运算符
            expression.remove(at: expression.characters.index(before: expression.endIndex))
        } else {
            // 将用户输入的操作数入栈
            stack.push(.operand(accumulator))
            updateResultText(isCalculation: false)
        }
        
        // 1+2+ || 1+2*3+
        // 执行之前的运算，1+2+ －> 3+ || 1+2*3+ -> 1+6+
        if stack.count >= 3 {
            if let operand2 = stack.pop(), let operators = stack.pop(), let operand1 = stack.pop() {
                // 备份操作历史
                backupStack.push(operand2)
                backupStack.push(operators)
                backupStack.push(operand1)
                computeAndPushResult(operand1: operand1, operators: operators, operand2: operand2)
            }
        }
        
        // 1+2*3+ -> 1+6+ -> 7+
        // 执行之前的运算
        if stack.count >= 3 {
            if let operand2 = stack.pop(), let operators = stack.pop(), let operand1 = stack.pop() {
                // 备份操作历史，operand2是上一次的运算结果，所以不需要备份
                backupStack.push(operators)
                backupStack.push(operand1)
                computeAndPushResult(operand1: operand1, operators: operators, operand2: operand2)
            }
        }
        
        // 将操作符入栈
        pushOperator(operation)
    }
    
    // 处理×、÷运算
    func handleHighOperation(_ operation: CalOperation) {
        // 前一个是运算符，出栈
        // userInput.isEmpty有两种情况，一种是前一个是运算符，二是相等操作
        // 所以用!isEquality排除不是相等操作的情况
        if isPreOperator /*userInput.isEmpty && !isEquality*/ {
            
            // 由低运算符变成高运算符，并且之前进行了数学运算，恢复以前的操作，由操作结果恢复成运算表达式
            if let topOperator = stack.topItem, topOperator.isLowPriorityOperator && backupStack.count > 0 {
                // 弹出前一个运算符
                stack.pop()
                //弹出运算结果
                stack.pop()
                
                // 恢复之前的操作表达式
                while let element = backupStack.pop() {
                    stack.push(element)
                }
                
                // 恢复之前的运算中间值
                if let topOperation = stack.topItem {
                    if case CalOperation.operand(let value) = topOperation {
                        accumulator = value
                        updateResultText(isCalculation: true)
                    }
                }
            } else {
                // 弹出前一个运算符
                stack.pop()
            }
            
            // 表达式删除前一个运算符
            expression.remove(at: expression.characters.index(before: expression.endIndex))
        } else {
            // 将用户输入的操作数入栈
            stack.push(.operand(accumulator))
            updateResultText(isCalculation: false)
        }
        
        // 1+2*3* -> 1+6*
        if stack.count >= 3 {
            if let previousOperator = stack.secondItem {
                switch previousOperator {
                case .multiplication, .division:
                    popToCompute()
                default:
                    break
                }
            }
        }
        
        // 将操作符入栈
        pushOperator(operation)
    }
    
    // 处理"＝"运算
    func handleEquality() {
        // 前一个是运算符，出栈
        if isPreOperator {
            // 弹出前一个运算符
            stack.pop()
            // 表达式删除前一个运算符
            expression.remove(at: expression.characters.index(before: expression.endIndex))
        } else {
            // 将用户输入的操作数入栈
            stack.push(.operand(accumulator))
            updateResultText(isCalculation: false)
        }
        
        expression += "="
        
        // 1+2= || 1*2= || 1+2*3=
        if stack.count >= 3 {
            popToCompute()
        }
        
        // 1+2*3= -> 1+6=
        if stack.count >= 3 {
            popToCompute()
        }
        
        // 清空userInput和栈
        userInput = ""
        stack.removeAll()
    }
    
    // 处理清空(C)操作
    func handleClearOperator() {
        resultLabel.text = "0"
        userInput = ""
        stack.removeAll()
        accumulator = 0.0
        preExpression = ""
        inputExpression = ""
        expression = ""
    }
    
    // 处理完成操作
    func handleComplication() {
        handleEquality()
        completion?(accumulator)
        navigationController?.popViewController(animated: true)
    }
    
    //MARK: - Help Methods
    // 将运算符入栈，清空userInput
    func pushOperator(_ operation: CalOperation) {
        stack.push(operation)
        expression += operation.character
        userInput = ""
    }
    
    /// 出栈，然后进行数值运算，最后把结果入栈
    func popToCompute() {
        if let operand2 = stack.pop(), let operators = stack.pop(), let operand1 = stack.pop() {
            computeAndPushResult(operand1: operand1, operators: operators, operand2: operand2)
        }
    }
    
    // 数学运算然后入栈和显示结果
    func computeAndPushResult(operand1: CalOperation, operators: CalOperation, operand2: CalOperation) {
        if let result = compute(operand1: operand1, operators: operators, operand2: operand2) {
            stack.push(.operand(result))
            accumulator = result
            updateResultText(isCalculation: true)
        }
    }
    
    /// 进行加减乘除数学运算
    func compute(operand1: CalOperation, operators: CalOperation, operand2: CalOperation) -> Double? {
        var result: Double? = nil
        if case CalOperation.operand(let value1) = operand1, case CalOperation.operand(let value2) = operand2 {
            switch operators {
            case .addition:
                result = value1 + value2
            case .subtraction:
                result = value1 - value2
            case .multiplication:
                result = value1 * value2
            case .division:
                result = value1 / value2
            default:
                break
            }
        }
        
        return result
    }
    
    // 更新resultLabel的内容
    func updateResultText(isCalculation: Bool) {
        if accumulator >= 1000000000 {
            formatter.numberStyle = .scientific
        } else {
            formatter.numberStyle = .decimal
        }
        let string = formatter.string(from: NSNumber(value: accumulator)) ?? "0"
        resultLabel.text = string
        
        if !isCalculation {
            inputExpression = string
        }
    }
    
    // 判断是否有小数点
    func userInputHasDot() -> Bool {
        return userInput.contains(".")
    }
}



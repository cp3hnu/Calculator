//
//  CalculatorCtrlr.swift
//  hnup
//
//  Created by CP3 on 16/5/12.
//  Copyright © 2016年 DataYP. All rights reserved.
//

import UIKit

struct CalStack<Element> {
    private var elements = [Element]()
    
    mutating func push(element: Element) {
        elements.append(element)
        
    #if DEBUG
        print("push", (element as! CalOperation).character)
        printArray()
    #endif
    }
    
    mutating func pop() -> Element? {
        let element = elements.popLast()
        
    #if DEBUG
        if let a = element {
            print("pop", (a as! CalOperation).character)
        } else {
            print("pop nil")
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
        print("(")
        for op in elements {
            print("\t", (op as! CalOperation).character, ",")
        }
        print(")\n")
    }
#endif
}

public final class Calculator: UIViewController {

    private let expressionLabel = UILabel().fontSize(24).textColor(UIColor(rgbHexValue: 0x999999)).alignRight()
    private let resultLabel = UILabel().fontSize(48).textColor(UIColor(rgbHexValue: 0x333333)).alignRight()
    private let formatter = NSNumberFormatter()
    
    // 记录用户输入的操作
    private var stack = CalStack<CalOperation>()
    // 备份执行的操作，主要用于用户输入"+/-"之后，变换成"×／÷"
    private var backupStack = CalStack<CalOperation>()
    
    // 记录用户输入的数字和小数点
    private var userInput = ""
    // 用户输入的数值或者计算出来的结果
    private var accumulator: Double = 0.0
    // 记录表达式
    private var expression = "" {
        didSet {
            expressionLabel.text = expression
        }
    }
    // 记录前一个不会变化的表达式
    private var preExpression = ""
    // 记录用户输入的数值表达式，这个值是不断变化和修正的
    private var inputExpression = "" {
        didSet {
            expression = preExpression + inputExpression
        }
    }
    
    // 标记是否输入了等号
    private var isPreEquality = true
    // 标记是否输入了运算符
    private var isPreOperator = false
    
    /// 计算完成回调，将计算结果返回
    public var completion: ((result: Double) -> Void)?
    
    public init() {
        super.init(nibName: nil, bundle: nil)
        
        formatter.numberStyle = .DecimalStyle
        formatter.alwaysShowsDecimalSeparator = false
        formatter.maximumFractionDigits = 8
        formatter.exponentSymbol = "e"
        formatter.positiveInfinitySymbol = "错误"
        formatter.negativeInfinitySymbol = "错误"
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "计算器"
        setupView()
    }
}

private extension Calculator {
    func setupView() {
        view.backgroundColor = UIColor.whiteColor()
        
        let resultBoardView = { () -> UIView in
            let resultView = UIView()
            resultView.backgroundColor = UIColor.whiteColor()
            expressionLabel.lineBreakMode = .ByTruncatingHead
            resultLabel.text = "0"
            resultLabel.adjustsFontSizeToFitWidth = true
            resultLabel.baselineAdjustment = .AlignCenters
            let space1 = UIView(), space2 = UIView(), space3 = UIView()
            
            resultView.addSubview(space1)
            resultView.addSubview(space2)
            resultView.addSubview(space3)
            resultView.addSubview(expressionLabel)
            resultView.addSubview(resultLabel)
            
            [space1, space2, space3, expressionLabel, resultLabel].forEach { view in
                view.translatesAutoresizingMaskIntoConstraints = false
            }
            
            resultView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[space1][expressionLabel(==29)][space2(==space1)][resultLabel][space3(==space1)]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["space1": space1, "space2": space2, "space3": space3, "expressionLabel": expressionLabel, "resultLabel": resultLabel]))
            resultView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[space1]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["space1": space1]))
            resultView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[space2]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["space2": space2]))
            resultView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[space3]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["space3": space3]))
            resultView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-15-[expressionLabel]-15-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["expressionLabel": expressionLabel]))
            resultView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-15-[resultLabel]-15-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["resultLabel": resultLabel]))

            return resultView
        }()
        let inputBoardView = CalInputView()
        resultBoardView.backgroundColor = UIColor.whiteColor()
        
        view.addSubview(resultBoardView)
        view.addSubview(inputBoardView)
        resultBoardView.translatesAutoresizingMaskIntoConstraints = false
        inputBoardView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[topGuide][resultBoardView][inputBoardView]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["topGuide": topLayoutGuide, "resultBoardView": resultBoardView, "inputBoardView": inputBoardView]))
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[resultBoardView]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["resultBoardView": resultBoardView]))
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[inputBoardView]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["inputBoardView": inputBoardView]))
        view.addConstraint(NSLayoutConstraint(item: resultBoardView, attribute: .Height, relatedBy: .Equal, toItem: inputBoardView, attribute: .Height, multiplier: 0.35, constant: 0))
        
        inputBoardView.userOperation = { [unowned self] operation in
            self.handleOperation(operation)
        }
    }
}

private extension Calculator {
    func handleOperation(operation: CalOperation) {
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
        case .Digit(let digit):
            handleDigit(digit)
        case .DecimalPoint:
            handleDot()
        case .Addition, .Subtraction:
            handleLowOperation(operation)
        case .Multiplication, .Division:
            handleHighOperation(operation)
        case .Equality:
            handleEquality()
        case .Clear:
            handleClearOperator()
        case .Completion:
            handleComplication()
        default:
            break
        }
        
        // 记录上一次的操作是不是等于操作，清空(C)相当于一个结果为0的等于操作
        switch operation {
        case .Equality, .Clear:
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
    func handleDigit(digit: Int) {
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
    func handleLowOperation(operation: CalOperation) {
        // 前一个是运算符，出栈
        if isPreOperator {
            //弹出前一个运算符
            stack.pop()
            // 表达式删除前一个运算符
            expression.removeAtIndex(expression.endIndex.predecessor())
        } else {
            // 将用户输入的操作数入栈
            stack.push(.Operand(accumulator))
            updateResultText(isCalculation: false)
        }
        
        // 1+2+ || 1+2*3+
        // 执行之前的运算，1+2+ －> 3+ || 1+2*3+ -> 1+6+
        if stack.count >= 3 {
            if let operand2 = stack.pop(), operators = stack.pop(), operand1 = stack.pop() {
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
            if let operand2 = stack.pop(), operators = stack.pop(), operand1 = stack.pop() {
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
    func handleHighOperation(operation: CalOperation) {
        // 前一个是运算符，出栈
        // userInput.isEmpty有两种情况，一种是前一个是运算符，二是相等操作
        // 所以用!isEquality排除不是相等操作的情况
        if isPreOperator /*userInput.isEmpty && !isEquality*/ {
            
            // 由低运算符变成高运算符，并且之前进行了数学运算，恢复以前的操作，由操作结果恢复成运算表达式
            if let topOperator = stack.topItem where topOperator.isLowPriorityOperator && backupStack.count > 0 {
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
                    if case CalOperation.Operand(let value) = topOperation {
                        accumulator = value
                        updateResultText(isCalculation: true)
                    }
                }
            } else {
                // 弹出前一个运算符
                stack.pop()
            }
            
            // 表达式删除前一个运算符
            expression.removeAtIndex(expression.endIndex.predecessor())
        } else {
            // 将用户输入的操作数入栈
            stack.push(.Operand(accumulator))
            updateResultText(isCalculation: false)
        }
        
        // 1+2*3* -> 1+6*
        if stack.count >= 3 {
            if let previousOperator = stack.secondItem {
                switch previousOperator {
                case .Multiplication, .Division:
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
            expression.removeAtIndex(expression.endIndex.predecessor())
        } else {
            // 将用户输入的操作数入栈
            stack.push(.Operand(accumulator))
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
        completion?(result: accumulator)
        navigationController?.popViewControllerAnimated(true)
    }
    
    //MARK: - Help Methods
    // 将运算符入栈，清空userInput
    func pushOperator(operation: CalOperation) {
        stack.push(operation)
        expression += operation.character
        userInput = ""
    }
    
    /// 出栈，然后进行数值运算，最后把结果入栈
    func popToCompute() {
        if let operand2 = stack.pop(), operators = stack.pop(), operand1 = stack.pop() {
            computeAndPushResult(operand1: operand1, operators: operators, operand2: operand2)
        }
    }
    
    // 数学运算然后入栈和显示结果
    func computeAndPushResult(operand1 operand1: CalOperation, operators: CalOperation, operand2: CalOperation) {
        if let result = compute(operand1: operand1, operators: operators, operand2: operand2) {
            stack.push(.Operand(result))
            accumulator = result
            updateResultText(isCalculation: true)
        }
    }
    
    /// 进行加减乘除数学运算
    func compute(operand1 operand1: CalOperation, operators: CalOperation, operand2: CalOperation) -> Double? {
        var result: Double? = nil
        if case CalOperation.Operand(let value1) = operand1, case CalOperation.Operand(let value2) = operand2 {
            switch operators {
            case .Addition:
                result = value1 + value2
            case .Subtraction:
                result = value1 - value2
            case .Multiplication:
                result = value1 * value2
            case .Division:
                result = value1 / value2
            default:
                break
            }
        }
        
        return result
    }
    
    // 更新resultLabel的内容
    func updateResultText(isCalculation isCalculation: Bool) {
        if accumulator >= 1000000000 {
            formatter.numberStyle = .ScientificStyle
        } else {
            formatter.numberStyle = .DecimalStyle
        }
        let string = formatter.stringFromNumber(accumulator) ?? "0"
        resultLabel.text = string
        
        if !isCalculation {
            inputExpression = string
        }
    }
    
    // 判断是否有小数点
    func userInputHasDot() -> Bool {
        return userInput.containsString(".")
    }
}



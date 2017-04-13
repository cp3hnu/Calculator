//
//  ViewController.swift
//  CalculatorDemo
//
//  Created by CP3 on 17/4/13.
//  Copyright © 2017年 CP3. All rights reserved.
//

import UIKit
import Calculator

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        view.backgroundColor = UIColor.whiteColor()
        
        let button = UIButton(type: .Custom)
        button.frame = CGRect(x: 0, y: 0, width: 100, height: 40)
        button.center = view.center
        button.setTitle("计算器", forState: .Normal)
        button.titleLabel?.font = UIFont.systemFontOfSize(16)
        button.setTitleColor(UIColor.blackColor(), forState: .Normal)
        button.addTarget(self, action: #selector(tap), forControlEvents: UIControlEvents.TouchUpInside)
        
        view.addSubview(button)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tap() {
        let calculator = Calculator()
        calculator.completion = { result in
            print(result)
        }
        navigationController?.pushViewController(calculator, animated: true)
    }
}


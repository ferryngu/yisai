//
//  YSCustomDatePickerViewController.swift
//  YISAI
//
//  Created by Yufate on 15/8/1.
//  Copyright (c) 2015年 Shenzhen Jianbo Information Technology Co., Ltd. All rights reserved.
//

import UIKit

protocol YSCustomDatePickerDelegate: NSObjectProtocol {
    
    // 隐藏DatePickerView
    func changeDateString(dateString: String)
}

class YSCustomDatePickerViewController: UIViewController {
    
    @IBOutlet weak var datePicker: UIDatePicker!
    
    private var dateString: String!
    var dateFormatter = NSDateFormatter()
    var isConfirm: Bool = false
    var delegate: YSCustomDatePickerDelegate!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        dateFormatter.dateFormat = "YYYY-MM-dd"
        dateString = dateFormatter.stringFromDate(NSDate())
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func showPicker() {
        UIView.animateWithDuration(0.5, animations: { [weak self] () -> Void in
            
            if self == nil {
                return
            }
            
            self!.view.alpha = 1
        })
    }
    
    private func hidePicker() {
        
        UIView.animateWithDuration(0.5, animations: { [weak self] () -> Void in
            
            if self == nil {
                return
            }
            
            self!.view.alpha = 0
        })
    }
    
    @IBAction func confirm(sender: AnyObject) {
        isConfirm = true
        
        if (self.delegate != nil) && (self.delegate.respondsToSelector("changeDateString:")) {
            self.delegate.changeDateString(self.dateString)
        }
        
        hidePicker()
    }
    
    @IBAction func cancel(sender: AnyObject) {
        isConfirm = false
        
        hidePicker()
    }
    
    @IBAction func datePickerEditingDidBegin(sender: UIDatePicker) {
        
        dateString = dateFormatter.stringFromDate(datePicker.date)
    }
    
    @IBAction func datePickerEditingChanged(sender: UIDatePicker) {
        
        dateString = dateFormatter.stringFromDate(datePicker.date)
    }
}

//
//  YSChildExperienceEditingViewController.swift
//  YISAI
//
//  Created by Yufate on 15/6/29.
//  Copyright (c) 2015年 Shenzhen Jianbo Information Technology Co., Ltd. All rights reserved.
//

import UIKit

class YSChildExperienceEditingViewController: UIViewController, UITextViewDelegate {

    @IBOutlet weak var textView: UITextView!
    var tips: FETips = FETips()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        tips.duration = 1
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewDidLoad()
        
        self.view.endEditing(true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Actions
    
    @IBAction func confirm(sender: AnyObject) {
        
        self.view.endEditing(true)
        
        if checkInputEmpty(textView.text) {
            tips.showTipsInMainThread(Text: "请输入简介信息")
            return
        }
        
        YSChildExperience.confirmChildExperience(textView.text, resp: { [weak self] (errorMsg: String!) -> Void in
            
            if self == nil {
                return
            }
            
            if errorMsg != nil {
                if self!.navigationController != nil {
                    self!.tips.showTipsInMainThread(Text: errorMsg)
                }
                return
            }
            
            delayCall(1.0, block: { () -> Void in
                self!.navigationController?.popViewControllerAnimated(true)
            })
        })
    }
    
    // MARK: - UITextViewDelegate
    
    func textViewShouldBeginEditing(textView: UITextView) -> Bool {
        
        if textView.text == "说点什么好呢？" {
            textView.text = nil
        }
        
        return true
    }

    func textViewShouldEndEditing(textView: UITextView) -> Bool {
        
        if checkInputEmpty(textView.text) {
            textView.text = "说点什么好呢？"
        }
        
        return true
    }
    
    func textViewDidChange(textView: UITextView) {
        
        if textView.text.characters.count > 100 {
            return
        }
    }
}

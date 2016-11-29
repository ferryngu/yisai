//
//  YSResetPasswordViewController.swift
//  YISAI
//
//  Created by Yufate on 15/8/21.
//  Copyright (c) 2015年 Shenzhen Jianbo Information Technology Co., Ltd. All rights reserved.
//

import UIKit

class YSResetPasswordViewController: UITableViewController {

    @IBOutlet weak var txf_password: UITextField!
    @IBOutlet weak var txf_verify: UITextField!
    
    var tips: FETips = FETips()
    var role_type: String!
    var telNum: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tips.duration = 1
        
        tableView.sectionHeaderHeight = 16
        tableView.rowHeight = 65.0
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        return 3
    }

    // MARK: - Actions

    @IBAction func reset(sender: AnyObject) {
        
        if role_type == nil || telNum == nil {
            return
        }
        
        view.endEditing(true)
        
        if checkInputEmpty(txf_password.text) {
            tips.showTipsInMainThread(Text: "请输入密码")
            return
        }
        
        if checkInputEmpty(txf_verify.text) {
            tips.showTipsInMainThread(Text: "请输入验证码")
            return
        }
        
        YSLogin.resetPasswd(role_type, phoneNum: telNum, password: txf_password.text!, vCode: txf_verify.text!) { [weak self] (errorMsg: String!) -> Void in
            
            if self == nil {
                return
            }
            
            if errorMsg != nil {
                return
            }
            
            self!.tips.showTipsInMainThread(Text: "密码修改成功")
            
            delayCall(1.0, block: { () -> Void in
                
                self!.dismissViewControllerAnimated(true, completion: nil)
            })
        }
    }
}

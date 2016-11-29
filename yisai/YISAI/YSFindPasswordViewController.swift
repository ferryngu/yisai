//
//  YSFindPasswordViewController.swift
//  YISAI
//
//  Created by Yufate on 15/8/21.
//  Copyright (c) 2015年 Shenzhen Jianbo Information Technology Co., Ltd. All rights reserved.
//

import UIKit

class YSFindPasswordViewController: UITableViewController {

    @IBOutlet weak var txf_tel: UITextField!
    
    var role_type: String!
    var tips: FETips = FETips()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        tableView.sectionHeaderHeight = 16
        tableView.rowHeight = 65.0
        
        tips.duration = 1
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
        return 2
    }

    // MARK: - Actions
    
    @IBAction func back(sender: AnyObject) {
        
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func sendVerify(sender: AnyObject) {
        
        view.endEditing(true)
        
        if checkInputEmpty(txf_tel.text) {
            tips.showTipsInMainThread(Text: "请输入手机号")
            return
        }
        
        if !checkTelNumber(txf_tel.text) {
            tips.showTipsInMainThread(Text: "手机号码格式有误")
            return
        }
        
        if role_type == nil {
            return
        }
        
        YSLogin.doVcode(phoneNum: txf_tel.text!) { [weak self] (errorMsg: String!) -> Void in
            
            if self == nil {
                return
            }
            
            if errorMsg != nil {
                self!.tips.showTipsInMainThread(Text: errorMsg)
                return
            }
            
            self!.tips.showTipsInMainThread(Text: "发送成功")
            
            delayCall(1.0, block: { () -> Void in
                
                if self?.navigationController != nil {
                    
                    let controller = self?.storyboard?.instantiateViewControllerWithIdentifier("YSResetPasswordViewController") as! YSResetPasswordViewController
                    controller.role_type = self!.role_type
                    controller.telNum = self!.txf_tel.text
                    self?.navigationController?.pushViewController(controller, animated: true)
                }
            })
        }
    }
}

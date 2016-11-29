//
//  YSMessageListViewController.swift
//  YISAI
//
//  Created by Yufate on 15/7/10.
//  Copyright (c) 2015年 Shenzhen Jianbo Information Technology Co., Ltd. All rights reserved.
//

import UIKit

class YSMessageListViewController: UITableViewController {

    var lst_message: [YSMessage]!
    var tips: FETips = FETips()
    var feiOSHttpImage: FEiOSHttpImage = FEiOSHttpImage()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.rowHeight = 70.0
        
        YSBudge.setReceivedMsg("0")
        
        tips.duration = 1
        
        fetchMessageList(true)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        

    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    // -------------------------------
    
    // MARK: - Logic Methods
    func fetchMessageList(shouldCache: Bool) {
        
//        if self.navigationController != nil {
//            tips.showActivityIndicatorViewInMainThread(navigationController!, text: nil)
//        }
        
        tips.showActivityIndicatorViewInMainThread(self, text: nil)
        
        YSMessage.getMsgList(shouldCache, start: 0, num: 99) { [weak self] (resp_lst_message: [YSMessage]!, errorMsg: String!) -> Void in
            
            if self == nil {
                return
            }
            
            self!.tips.disappearActivityIndicatorViewInMainThread()
            
            if errorMsg != nil {
                self!.tips.showTipsInMainThread(Text: errorMsg)
                return
            }
            
            self!.lst_message = resp_lst_message
            self!.tableView.reloadData()
        }
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
        return lst_message == nil ? 0 : lst_message.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("YSMessageListNormalCell", forIndexPath: indexPath)

        if lst_message == nil {
            return cell
        }
        
        let message = lst_message[indexPath.row]
        let img_avatar = cell.contentView.viewWithTag(11) as! UIImageView
        let lab_name = cell.contentView.viewWithTag(12) as! UILabel
        let lab_content = cell.contentView.viewWithTag(13) as! UILabel
        let lab_time = cell.contentView.viewWithTag(14) as! UILabel
        
        img_avatar.image = feiOSHttpImage.asyncHttpImageInUIThread(message.sender_avatar!, defaultImageName:DEFAULT_AVATAR, finishCallbackInUIThread: {
            [weak self] (handler: FEiOSHttpImageHandler) -> Void in
            if self == nil { return }
            img_avatar.image = self!.feiOSHttpImage.loadImageInCache(message.sender_avatar!).0
            })
        lab_name.text = message.sender_username
        lab_content.text = message.content
        
        if message.role_type != nil &&  message.role_type == "1" {
            
            let lab_level = cell.contentView.viewWithTag(15) as! UILabel
            lab_level.text = "Lv.\(message.level) \(message.level_name)"
            let level_bg = cell.contentView.viewWithTag(16) as! UIImageView
            level_bg.hidden = false
        }
        
        let formatString = formatTimeInterval((message.update_time as NSString).doubleValue, type: 2)
        if formatString == nil {
            lab_time.text = ""
        } else {
            lab_time.text = handleTime(formatString!, style: 1)
        }

        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        if lst_message == nil {
            return
        }
        
        let message = lst_message[indexPath.row]
        let controller = self.storyboard?.instantiateViewControllerWithIdentifier("YSMyMessageViewController") as! YSMyMessageViewController
        if message.role_type != nil {
            controller.role_type = Int(message.role_type)
        }
        controller.fuid = message.sender_id
        controller.avatarUrlStr = message.sender_avatar
        controller.title = message.sender_username
        self.navigationController?.pushViewController(controller, animated: true)
    }
}

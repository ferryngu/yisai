//
//  YSMyMessageViewController.swift
//  YISAI
//
//  Created by Yufate on 15/7/11.
//  Copyright (c) 2015年 Shenzhen Jianbo Information Technology Co., Ltd. All rights reserved.
//

import UIKit

class YSMyMessageViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var rightBarItem: UIBarButtonItem!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var loc_bottomView_bottom: NSLayoutConstraint!
    @IBOutlet weak var loc_bottomView_height: NSLayoutConstraint!
    
    var feiOSHttpImage: FEiOSHttpImage = FEiOSHttpImage()
    var fuid: String!
    var userName: String!
    var avatarUrlStr: String!
    var lst_messages: [YSMessage]!
    var tips: FETips = FETips()
    var maxTextHeight: CGFloat = 85
    var lastOffset: CGFloat = 0.0
    let label = UILabel()
    var role_type: Int!
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tips = FETips()
        tips.duration = 1

        configureRightItem()
        configureCountHeightLabel()
        fetchMessages()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func configureCountHeightLabel() {
        
        label.numberOfLines = 0
        label.lineBreakMode = NSLineBreakMode.ByCharWrapping
        label.font = UIFont.systemFontOfSize(17.0)
    }
    
    func configureRightItem() {
        
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
        imageView.layer.cornerRadius = 15.0
        imageView.clipsToBounds = true
        imageView.userInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer(target: self, action: "gotoFPersonalInfo:")
        imageView.addGestureRecognizer(tapGesture)
        if avatarUrlStr != nil {
            imageView.image = feiOSHttpImage.asyncHttpImageInUIThread(avatarUrlStr, defaultImageName:DEFAULT_AVATAR, finishCallbackInUIThread: {
                [weak self] (handler: FEiOSHttpImageHandler) -> Void in
                if self == nil { return }
                imageView.image = self!.feiOSHttpImage.loadImageInCache(self!.avatarUrlStr).0
                })
        } else {
            imageView.image = UIImage(named: DEFAULT_AVATAR)
        }
        self.rightBarItem.customView = imageView
    }
    
    func fetchMessages() {
        
        if fuid == nil {
            return
        }
        
//        if self.navigationController != nil {
//            tips.showActivityIndicatorViewInMainThread(navigationController!, text: nil)
//        }
        
        tips.showActivityIndicatorViewInMainThread(self, text: nil)
        
        YSMessage.getFuidMsg(fuid, start: 0, num: 9999) { [weak self] (resp_messages: [YSMessage]!, errorMsg: String!) -> Void in
            
            if self == nil {
                return
            }
            
            self!.tips.disappearActivityIndicatorViewInMainThread()
            
            if errorMsg != nil {
                self!.tips.showTipsInMainThread(Text: errorMsg)
                return
            }
            
            self!.lst_messages = resp_messages
            self!.tableView.reloadData()
            
            if self!.tableView.contentSize.height >= self!.tableView.bounds.size.height {
                self!.tableView.contentOffset.y = self!.tableView.contentSize.height - self!.tableView.bounds.size.height
            }
        }
    }
    
    // 跳转到普通用户个人主页
    func gotoUserPage(uid: String) {
        
        let controller = UIStoryboard(name: "YSMine", bundle: nil).instantiateViewControllerWithIdentifier("YSUserPersonalInfoViewController") as! YSUserPersonalInfoViewController
        controller.fuid = uid
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    // 跳转到评委个人主页
    func gotoJudgePage(uid: String) {
        
        let controller = UIStoryboard(name: "YSMine", bundle: nil).instantiateViewControllerWithIdentifier("YSTNJPersonalInfoViewController") as! YSTNJPersonalInfoViewController
        controller.aid = uid
        controller.role_type = RoleType.Judge
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    // 跳转到老师个人主页
    func gotoTeacherPage(uid: String) {
        
        let controller = UIStoryboard(name: "YSMine", bundle: nil).instantiateViewControllerWithIdentifier("YSTNJPersonalInfoViewController") as! YSTNJPersonalInfoViewController
        controller.role_type = RoleType.Tutor
        controller.aid = uid
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    // 跳转到既是评委又是老师的个人主页
    func gotoJNTPage(uid: String) {
        
        let controller = UIStoryboard(name: "YSMine", bundle: nil).instantiateViewControllerWithIdentifier("YSTNJPersonalInfoViewController") as! YSTNJPersonalInfoViewController
        controller.aid = uid
        controller.role_type = RoleType.JudgeAndTutor
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    func sendMsg() {
        
        self.view.endEditing(true)
        
        if checkInputEmpty(textView.text) || fuid == nil {
            return
        }
        
        let tText = textView.text
        
        YSMessage.sendMsg(tText, fuid: fuid) { [weak self] (errorMsg: String!) -> Void in
            
            if self == nil {
                return
            }
            
            if errorMsg != nil {
                self!.tips.showTipsInMainThread(Text: errorMsg)
                return
            }
        }
        
        let message = YSMessage()
//        let dateNow = NSDate()
        message.update_time = "\(NSDate().timeIntervalSince1970 * 1000)"
        message.send_time = "\(NSDate().timeIntervalSince1970 * 1000)"
        message.sender_id = ysApplication.loginUser.uid
        message.content = tText
        
        lst_messages.append(message)
        tableView.reloadData()
        
        label.text = message.content
//        let labelHeight = label.sizeThatFits(CGSize(width: SCREEN_WIDTH-116-24, height: 9999)).height
        if tableView.contentSize.height >= tableView.bounds.size.height {
            tableView.contentOffset.y = tableView.contentSize.height - tableView.bounds.size.height
        }
        
        textView.text = ""
        loc_bottomView_height.constant = 51
    }
    
    // MARK: - Actions
    
    @IBAction func resignInput(sender: AnyObject) {
        
        if textView.isFirstResponder() {
            textView.resignFirstResponder()
        }
    }
    
    func gotoFPersonalInfo(sender: AnyObject) {
        
        if fuid == nil {
            return
        }
        
        if navigationController == nil {
            return
        }
        
        let childViewControllers = navigationController!.childViewControllers
        var findFlag = false
        
        for viewController in childViewControllers {
            
            if viewController is YSUserPersonalInfoViewController && role_type == 1 {
                
                findFlag = true
                
                (viewController as! YSUserPersonalInfoViewController).fuid = fuid
                navigationController!.popToViewController(viewController , animated: true)
                
                break
            }
            
            if viewController is YSTNJPersonalInfoViewController && role_type != 1 {
                
                findFlag = true
                
                (viewController as! YSTNJPersonalInfoViewController).aid = fuid
                navigationController!.popToViewController(viewController , animated: true)
                
                break
            }
        }
        
        if findFlag {
            return
        }
        
        switch role_type {
        case 1:
            gotoUserPage(fuid)
        case 2:
            gotoJudgePage(fuid)
        case 3:
            gotoTeacherPage(fuid)
        case 4:
            gotoJNTPage(fuid)
        default:
            break
        }
    }
    
    @IBAction func sendMsg(sender: AnyObject) {
        
        sendMsg()
    }

    // MARK: - Table view data source

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return 1
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        return lst_messages == nil ? 0 : lst_messages.count
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let myCell = tableView.dequeueReusableCellWithIdentifier("YSMyMessageMyCell")
        let otherCell = tableView.dequeueReusableCellWithIdentifier("YSMyMessageOtherCell")

        if lst_messages == nil {
            return myCell!
        }
        
        let message = lst_messages[indexPath.row]
        if message.sender_id == ysApplication.loginUser.uid {
            
            let lab_date = myCell!.contentView.viewWithTag(11) as! UILabel
            let lab_content = myCell!.contentView.viewWithTag(12) as! UILabel
//            let img_bg = myCell!.contentView.viewWithTag(13) as! UIImageView
            
//            var sameDay = false
//            if indexPath.row - 1 >= 0 {
//                let lastMessage = lst_messages[indexPath.row - 1]
//                sameDay = isSameDay(NSDate(timeIntervalSince1970: (message.update_time as NSString).doubleValue / 1000.0), theOtherDay: NSDate(timeIntervalSince1970: (lastMessage.update_time as NSString).doubleValue / 1000.0))
//            }
//            if sameDay {
//                lab_date.hidden = true
//            } else {
//                lab_date.hidden = false
            let formatString = formatTimeInterval((message.update_time as NSString).doubleValue, type: 2)
            lab_date.text = handleTime(formatString!, style: 1)
//            }
            lab_content.text = message.content
//            let height = lab_content.sizeThatFits(CGSize(width: SCREEN_WIDTH-116-24, height: 999)).height
//            for constraint in lab_content.constraints() {
//                if (constraint as! NSLayoutConstraint).firstAttribute == NSLayoutAttribute.Height {
//                    (constraint as! NSLayoutConstraint).constant = height > 21 ? height : 21
//                }
//            }
//            if sameDay {
//                for constraint in lab_content.superview!.constraints() {
//                    if (constraint as! NSLayoutConstraint).firstItem as? UILabel == lab_content && (constraint as! NSLayoutConstraint).firstAttribute == NSLayoutAttribute.Top {
//                        (constraint as! NSLayoutConstraint).constant = 16
//                    }
//                }
//            }
            
            return myCell!
            
        } else {
            
            let lab_date = otherCell!.contentView.viewWithTag(11) as! UILabel
            let lab_content = otherCell!.contentView.viewWithTag(12) as! UILabel
//            let img_bg = otherCell!.contentView.viewWithTag(13) as! UIImageView
            
//            var sameDay = false
//            if indexPath.row - 1 >= 0 {
//                let lastMessage = lst_messages[indexPath.row - 1]
//                sameDay = isSameDay(NSDate(timeIntervalSince1970: (message.update_time as NSString).doubleValue / 1000.0), theOtherDay: NSDate(timeIntervalSince1970: (lastMessage.update_time as NSString).doubleValue / 1000.0))
//            }
//            if sameDay {
//                lab_date.hidden = true
//            } else {
//                lab_date.hidden = false
            let formatString = formatTimeInterval((message.update_time as NSString).doubleValue, type: 2)
            lab_date.text = handleTime(formatString!, style: 1)
//            }
            lab_content.text = message.content
            let height = lab_content.sizeThatFits(CGSize(width: SCREEN_WIDTH-116-24, height: 9999)).height
            for constraint in lab_content.constraints {
                if constraint.firstAttribute == NSLayoutAttribute.Height {
                    constraint.constant = height > 21 ? height : 21
                }
            }
//            if sameDay {
//                for constraint in lab_content.superview!.constraints() {
//                    if (constraint as! NSLayoutConstraint).firstItem as? UILabel == lab_content && (constraint as! NSLayoutConstraint).firstAttribute == NSLayoutAttribute.Top {
//                        (constraint as! NSLayoutConstraint).constant = 16
//                    }
//                }
//            }
            return otherCell!
        }
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
    
        if lst_messages == nil {
            return 0.0
        }
        
        let message = lst_messages[indexPath.row]
        label.text = message.content
        let labelHeight = label.sizeThatFits(CGSize(width: (SCREEN_WIDTH-16) * 460.0 / 584.0, height: 9999)).height
        
        var sameDay = false
        if indexPath.row - 1 >= 0 {
            let lastMessage = lst_messages[indexPath.row - 1]
            sameDay = isSameDay(NSDate(timeIntervalSince1970: (message.update_time as NSString).doubleValue / 1000.0), theOtherDay: NSDate(timeIntervalSince1970: (lastMessage.update_time as NSString).doubleValue / 1000.0))
        }
        
        return (labelHeight > 21 ? labelHeight : 21) + 48 + 14
    }
    
    // MARK: Notification
    
    func keyboardWillShow(notification: NSNotification) {
        
        let kbSize = notification.userInfo![UIKeyboardFrameEndUserInfoKey]?.CGRectValue.size
        let duration = notification.userInfo![UIKeyboardAnimationDurationUserInfoKey]!.doubleValue
//        let curve = notification.userInfo![UIKeyboardAnimationCurveUserInfoKey]!.integerValue
        
        UIView.animateWithDuration(duration, delay: 0, options: UIViewAnimationOptions.CurveEaseOut, animations: { () -> Void in
            self.loc_bottomView_bottom.constant = kbSize!.height
            
//            if self.tableView.contentSize.height >= self.tableView.bounds.size.height {
//                self.tableView.contentOffset.y = self.tableView.contentSize.height - self.tableView.bounds.size.height
//            }
        }, completion: nil)
    }
    
    func keyboardWillHide(notification: NSNotification) {
        
//        let kbSize = notification.userInfo![UIKeyboardFrameEndUserInfoKey]?.CGRectValue.size
        let duration = notification.userInfo![UIKeyboardAnimationDurationUserInfoKey]!.doubleValue
//        let curve = notification.userInfo![UIKeyboardAnimationCurveUserInfoKey]!.integerValue
        
        UIView.animateWithDuration(duration, delay: 0, options: UIViewAnimationOptions.CurveEaseOut, animations: { () -> Void in
            self.loc_bottomView_bottom.constant = 0
            }, completion: nil)
    }
    
    // MARK: - UITextViewDelegate
    
    func textViewDidChange(textView: UITextView) {
        
        var height = textView.contentSize.height + 10 + 8
        if height <= 51 {
            height = 51
        } else if height >= maxTextHeight {
            height = maxTextHeight
        }
        
        UIView.animateWithDuration(0.5, animations: { [weak self] () -> Void in
            if self == nil {
                return
            }
            
            self!.loc_bottomView_height.constant = height
        })
        
        textView.scrollRangeToVisible(textView.selectedRange)
    }
    
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        
        if text == "\n" {
            
            sendMsg()
        }
        
        return true
    }
    
    // MARK: - UIScrollViewDelegate
    
//    func scrollViewDidScroll(scrollView: UIScrollView) {
//        
//        for gesture in scrollView.gestureRecognizers! {
//            if gesture is UIPanGestureRecognizer {
//                if textView.isFirstResponder() {
//                    textView.resignFirstResponder()
//                }
//            }
//        }
//    }
}

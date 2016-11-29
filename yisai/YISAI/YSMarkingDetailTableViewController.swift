//
//  YSMarkingDetailTableViewController.swift
//  YISAI
//
//  Created by 李瀚 on 16/1/12.
//  Copyright © 2016年 Shenzhen Jianbo Information Technology Co., Ltd. All rights reserved.
//

import UIKit

class YSMarkingDetailTableViewController: UITableViewController, UITextFieldDelegate, UITextViewDelegate {
    
    var crid: String!
    var marking_info: YSMarkingCompetitionInfo!
    
    var tips: FETips = FETips()
    var feiOSHttpImage: FEiOSHttpImage = FEiOSHttpImage()

    var isConfirm: Bool = false
    var commentText: String!
    
    //topcell
    @IBOutlet weak var img_avatar: UIImageView!
    @IBOutlet weak var lab_name: UILabel!
    @IBOutlet weak var lab_title: UILabel!
    //markingcell
    @IBOutlet weak var txf_score: UITextField!
    @IBOutlet weak var txv_comment: UITextView!
    @IBOutlet weak var lab_commentTextCount: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tips.duration = 1
        self.view.resignFirstResponder()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.navigationBarHidden = true
        
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        tableView.reloadData()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.navigationController?.navigationBarHidden = false
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func configureTableView() {
        
        lab_name.text = marking_info.username
        lab_title.text = marking_info.title
        img_avatar.image = feiOSHttpImage.asyncHttpImageInUIThread(marking_info.avatar, defaultImageName:DEFAULT_AVATAR, finishCallbackInUIThread: {
            [weak self] (handler: FEiOSHttpImageHandler) -> Void in
            if self == nil { return }
            self!.img_avatar.image = self!.feiOSHttpImage.loadImageInCache(self!.marking_info.avatar).0
            })
    }

    // MARK: - Table view data source
//
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
//
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 3
    }
//
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        switch indexPath.row {
        case 0:
            return 92.0
        case 1:
            return 182.0
        default:
            return 58.0
        }
    }
    

    //MArk: Action

    @IBAction func confirm() {
        if marking_info == nil || crid == nil {
            return
        }
        if checkInputEmpty(txf_score.text) {
            tips.showTipsInMainThread(Text: "请输入你的评分")
            return
        } else if checkInputEmpty(commentText) {
            tips.showTipsInMainThread(Text: "请输入你的作品评论")
            return
        } else if Int(txf_score.text!) != nil && Int(txf_score.text!) > 100 {
            tips.showTipsInMainThread(Text: "你的评分大于100分")
            return
        }
        
        if isConfirm {
            tips.showTipsInMainThread(Text: "正在提交评分")
            return
        }
        
        isConfirm = true
        
        YSCompetition.confirmFindworkScore(crid, point: txf_score.text!, content: commentText) { [weak self] (errorMsg: String!) -> Void in
            
            if self == nil {
                return
            }
            
            if errorMsg != nil {
                
                self!.isConfirm = false
                
                self!.tips.showTipsInMainThread(Text: errorMsg)
                return
            }
            
            self!.tips.showTipsInMainThread(Text: "评分提交成功")
            delayCall(1.0, block: { () -> Void in
                self?.navigationController?.popViewControllerAnimated(true)
            })
        }
    }
    
    @IBAction func resignInputs(sender: AnyObject) {
        txf_score.resignFirstResponder()
        txv_comment.resignFirstResponder()
    }
    
    
    // MARK: - UITextFieldDelegate
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        
        if string == "" {
            return true
        }
        
        if textField.text?.characters.count >= 3 {
            return false
        }
        
        return true
    }
    func textFieldDidBeginEditing(textField: UITextField) {
        textField.text = ""
    }
    
//    // MARK: - UITextViewDelegate
    
    func textViewDidBeginEditing(textView: UITextView) {
        
        if textView.text == "发表句评论吧。你的意见可能会对参赛者选手有很大的帮助喔！" {
            textView.text = ""
            commentText = ""
        }
    }
    
    func textViewShouldEndEditing(textView: UITextView) -> Bool {
        
        if checkInputEmpty(textView.text) {
            textView.text = "发表句评论吧。你的意见可能会对参赛者选手有很大的帮助喔！"
        }
        return true
    }
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        
        if text == "" {
            return true
        }
        
        if textView.text.characters.count > 50 {
            return false
        }
        
        return true
    }
    
    func textViewDidChange(textView: UITextView) {
        
        if textView.text != "发表句评论吧。你的意见可能会对参赛者选手有很大的帮助喔！" {
            commentText = textView.text
        }
        
        if textView.text.characters.count > 50 {
            commentText = (commentText as NSString).substringToIndex(50)
            textView.text = commentText
        }
        
        lab_commentTextCount.text = "\(commentText.characters.count)/50"
    }
}

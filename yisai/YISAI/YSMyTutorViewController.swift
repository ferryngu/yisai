//
//  YSMyTutorViewController.swift
//  YISAI
//
//  Created by Yufate on 15/6/30.
//  Copyright (c) 2015年 Shenzhen Jianbo Information Technology Co., Ltd. All rights reserved.
//

import UIKit

class YSMyTutorViewController: UITableViewController {
    
    private struct AssociatedObject {
        static var GetTutor = "GetTutor"
    }
    
    var aid: String! // 指导老师ID
    var currentTutor: YSChildTutor! // 当前导师
    var lst_tutor: [YSChildTutor]! // 导师列表
    var tips: FETips = FETips()
    var feiOSHttpImage: FEiOSHttpImage = FEiOSHttpImage()

    override func viewDidLoad() {
        super.viewDidLoad()
        //----------potatoes-----------
        self.view.backgroundColor = UIColor.whiteColor()
        //----------potatoes-----------
        
        tips.duration = 1
        
        let tutor = YSFindworkTutor.getTutor()
        if tutor != nil {
            YSFindworkTutor.setTutor(tutor!)
        }
        
        fetchTutor(true)
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
    func fetchTutor(shouldCache: Bool) {
        
//        if self.navigationController != nil {
//            tips.showActivityIndicatorViewInMainThread(navigationController!, text: nil)
//        }
        
        tips.showActivityIndicatorViewInMainThread(self, text: nil)
        
        YSTutor.fetchChildTutor(shouldCache, startIndex: 0, num: 99) { [weak self] (resp_tutor: YSChildTutor!, resp_lst_tutor: [YSChildTutor]!, errorMsg: String!) -> Void in
            
            if self == nil {
                return
            }
            
            self!.tips.disappearActivityIndicatorViewInMainThread()
            
            if errorMsg != nil {
                self!.tips.showTipsInMainThread(Text: errorMsg)
                return
            }
            
            self!.currentTutor = resp_tutor
            self!.lst_tutor = resp_lst_tutor
            self!.tableView.reloadData()
        }
    }
    
    // MARK: - Actions
    
    func gotoTutorInfo(button: UIButton) {
        
        let tutor = objc_getAssociatedObject(button, &AssociatedObject.GetTutor) as? YSChildTutor
        
        if tutor == nil || tutor?.aid == nil {
            
            tips.showTipsInMainThread(Text: "当前没有指导老师哦")
            return
        }
        
        let controller = self.storyboard?.instantiateViewControllerWithIdentifier("YSTNJPersonalInfoViewController") as! YSTNJPersonalInfoViewController
        controller.aid = tutor!.aid
        self.navigationController?.pushViewController(controller, animated: true)
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
        return (currentTutor == nil || lst_tutor == nil || lst_tutor.count < 1) ? 2 : (2 + (lst_tutor.count - 1) / 5 + 1)
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        switch indexPath.row {
        case 0:
            return 16 + 39 + SCREEN_WIDTH * 108 / 414
        case 1:
            return 50
        default:
            return SCREEN_WIDTH / 5 - 16 + 15 + 44
        }
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        switch indexPath.row {
        case 0:
            let cell = tableView.dequeueReusableCellWithIdentifier("YSMyTutorTopCell")
            
            if currentTutor == nil {
                return cell!
            }
            
            let img_avatar = cell!.contentView.viewWithTag(11) as! UIImageView
            let lab_name = cell!.contentView.viewWithTag(12) as! UILabel
            let btn_avatar = cell!.contentView.viewWithTag(13) as! UIButton
            
            img_avatar.layer.cornerRadius = SCREEN_WIDTH * 108 / 414 / 2
            
            img_avatar.image = feiOSHttpImage.asyncHttpImageInUIThread(currentTutor.avatar, defaultImageName:DEFAULT_AVATAR, finishCallbackInUIThread: {
                [weak self] (handler: FEiOSHttpImageHandler) -> Void in
                if self == nil { return }
                img_avatar.image = self!.feiOSHttpImage.loadImageInCache(self!.currentTutor.avatar).0
                })
            
            lab_name.text = checkInputEmpty(currentTutor.realname) ? "指导老师" : currentTutor.realname
            if checkInputEmpty(currentTutor.aid) {
                
                objc_setAssociatedObject(btn_avatar, &AssociatedObject.GetTutor, nil, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            } else {
                
                objc_setAssociatedObject(btn_avatar, &AssociatedObject.GetTutor, currentTutor, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            }
            
            btn_avatar.addTarget(self, action: "gotoTutorInfo:", forControlEvents: .TouchUpInside)
            
            return cell!
        case 1:
            let cell = tableView.dequeueReusableCellWithIdentifier("YSMyTutorOtherCell")
            return cell!
        default:
            let cell = tableView.dequeueReusableCellWithIdentifier("YSMyTutorNormalCell")
            
            if currentTutor == nil || lst_tutor == nil || lst_tutor.count < 1 {
                return cell!
            }
            
            for i in 1...5 {
                
                if 5 * (indexPath.row - 2) + i > lst_tutor.count {
                    break
                }
                
                let tView = cell!.contentView.viewWithTag(i)
                tView?.hidden = false
                
                let tutor = lst_tutor[5 * (indexPath.row - 2) + i - 1]
                let img_avatar = tView?.viewWithTag(11) as! UIImageView
                let lab_name = tView?.viewWithTag(12) as! UILabel
                let lab_date = tView?.viewWithTag(13) as! UILabel
                let btn_tutor = tView?.viewWithTag(14) as! UIButton
                
                img_avatar.layer.cornerRadius = (SCREEN_WIDTH / 5 - 16) / 2
//                fe_ios_http_image(tutor.avatar, defaultImageName: DEFAULT_AVATAR, imageView: img_avatar)
                img_avatar.image = feiOSHttpImage.asyncHttpImageInUIThread(tutor.avatar, defaultImageName:DEFAULT_AVATAR, finishCallbackInUIThread: {
                    [weak self] (handler: FEiOSHttpImageHandler) -> Void in
                    if self == nil { return }
                    img_avatar.image = self!.feiOSHttpImage.loadImageInCache(tutor.avatar).0
                    })
                lab_name.text = checkInputEmpty(tutor.realname) ? "指导老师" : tutor.realname
                lab_date.text = tutor.update_time
                objc_setAssociatedObject(btn_tutor, &AssociatedObject.GetTutor, tutor, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
                btn_tutor.addTarget(self, action: "gotoTutorInfo:", forControlEvents: .TouchUpInside)
            }
            
            return cell!
        }
    }
}

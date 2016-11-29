//
//  YSOrganizationInviteViewController.swift
//  YISAI
//
//  Created by Yufate on 15/7/24.
//  Copyright (c) 2015年 Shenzhen Jianbo Information Technology Co., Ltd. All rights reserved.
//

import UIKit

class YSOrganizationInviteViewController: UITableViewController {

    private struct AssociatedObject {
        static var GetInvitation = "GetInvitation"
    }
    
    var tips: FETips = FETips()
    var lst_invitation: [YSOrganization]!
    var feiOSHttpImage: FEiOSHttpImage = FEiOSHttpImage()
    override func viewDidLoad() {
        super.viewDidLoad()

        tips = FETips()
        tips.duration = 1
        
        tableView.rowHeight = 126.0
        
        fetchInvitationInfo()
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
    func fetchInvitationInfo() {
        
//        if self.navigationController != nil {
//            tips.showActivityIndicatorViewInMainThread(navigationController!, text: nil)
//        }
        
        tips.showActivityIndicatorViewInMainThread(self, text: nil)
        
        YSTutor.fetchOrganizationInvited { [weak self] (resp_lst_invitation: [YSOrganization]!, errorMsg: String!) -> Void in
            
            if self == nil {
                return
            }
            
            self!.tips.disappearActivityIndicatorViewInMainThread()
            
            if errorMsg != nil {
                self!.tips.showTipsInMainThread(Text: errorMsg)
                return
            }
            
            self!.lst_invitation = resp_lst_invitation
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
        return lst_invitation == nil ? 0 : lst_invitation.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("YSOrganizationInviteCell", forIndexPath: indexPath)

        if lst_invitation == nil || lst_invitation.count < 1 {
            return cell
        }
        
        let invitation = lst_invitation[indexPath.row]
        let img_logo = cell.contentView.viewWithTag(11) as! UIImageView
        let lab_name = cell.contentView.viewWithTag(12) as! UILabel
        let lab_content = cell.contentView.viewWithTag(13) as! UILabel
        let lab_date = cell.contentView.viewWithTag(14) as! UILabel
        let btn_refuse = cell.contentView.viewWithTag(15) as! UIButton
        let btn_accept = cell.contentView.viewWithTag(16) as! UIButton
        
        img_logo.image = feiOSHttpImage.asyncHttpImageInUIThread(invitation.institution_logo, defaultImageName:DEFAULT_IMAGE_NAME_RECTANGLE, finishCallbackInUIThread: {
            [weak self] (handler: FEiOSHttpImageHandler) -> Void in
            if self == nil { return }
            img_logo.image = self!.feiOSHttpImage.loadImageInCache(invitation.institution_logo).0
            })
        
        lab_name.text = invitation.institution_name
        lab_content.text = invitation.content
        lab_date.text = invitation.update_time
        btn_refuse.addTarget(self, action: "invitationWithStatus:", forControlEvents: .TouchUpInside)
        btn_accept.addTarget(self, action: "invitationWithStatus:", forControlEvents: .TouchUpInside)
        objc_setAssociatedObject(btn_refuse, &AssociatedObject.GetInvitation, invitation, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        objc_setAssociatedObject(btn_accept, &AssociatedObject.GetInvitation, invitation, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)

        return cell
    }
    
    // MARK: - Actions 
    
    func invitationWithStatus(sender: UIButton) {
        
        if lst_invitation == nil || lst_invitation.count < 1 {
            return
        }
        
        let invitation = objc_getAssociatedObject(sender, &AssociatedObject.GetInvitation) as? YSOrganization
        if invitation == nil || invitation?.iid == nil || invitation?.cpid == nil {
            return
        }
        
        let status = sender.tag == 15 ? 2 : 1
        
        YSTutor.invitationWithStatus(status, iid: invitation!.iid, cpid: invitation!.cpid) { [weak self] (errorMsg: String!) -> Void in
            
            if self == nil {
                return
            }
            
            if errorMsg != nil {
                self!.tips.showTipsInMainThread(Text: errorMsg)
                return
            }
            
            if self!.lst_invitation.indexOf(invitation!) == nil {
                return
            }
            
            self?.lst_invitation.removeAtIndex(self!.lst_invitation.indexOf(invitation!)!)
            self!.tableView.reloadData()
        }
        
    }
}

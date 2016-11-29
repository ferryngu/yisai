//
//  YSOrganizationJoinedViewController.swift
//  YISAI
//
//  Created by Yufate on 15/7/24.
//  Copyright (c) 2015年 Shenzhen Jianbo Information Technology Co., Ltd. All rights reserved.
//

import UIKit

class YSOrganizationJoinedViewController: UITableViewController {

    var tips: FETips = FETips()
    var feiOSHttpImage: FEiOSHttpImage = FEiOSHttpImage()
    
    var lst_org_joined: [YSOrganization]!
    var lst_org_current: [YSOrganization]!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        YSBudge.setInstitutionInvitation("0")
        
        tips.duration = 1
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        fetchOrganizationJoined()
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
    
    func fetchOrganizationJoined() {
        
//        if self.navigationController != nil {
//            tips.showActivityIndicatorViewInMainThread(navigationController!, text: nil)
//        }
        
        tips.showActivityIndicatorViewInMainThread(self, text: nil)
        
        YSTutor.fetchOrganizationJoined() { [weak self] (resp_lst_org_current: [YSOrganization]!, resp_lst_org_joined: [YSOrganization]!, errorMsg: String!) -> Void in
            
            if self == nil {
                return
            }
            
            self!.tips.disappearActivityIndicatorViewInMainThread()
            
            if errorMsg != nil {
                self!.tips.showTipsInMainThread(Text: errorMsg)
                return
            }
            
            self!.lst_org_current = resp_lst_org_current
            self!.lst_org_joined = resp_lst_org_joined
            self!.tableView.reloadData()
        }
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return 2
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        if section == 0 {
            return lst_org_current == nil ? 1 : 1 + lst_org_current.count
        } else {
            return lst_org_joined == nil ? 1 : 1 + lst_org_joined.count
        }
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.section == 0 {
            
            if indexPath.row == 0 {
                return 40.0
            } else {
                return 97.0
            }
        } else {
            
            if indexPath.row == 0 {
                return 40.0
            } else {
                return 72.0
            }
            
        }
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {

        if indexPath.section == 0 {
            
            if indexPath.row == 0 {
                
                let cell = tableView.dequeueReusableCellWithIdentifier("YSOrganizationJoinedTitleCell", forIndexPath: indexPath)
                
                cell.backgroundColor = UIColor.whiteColor()
                
                let leftView = cell.contentView.viewWithTag(11)
                let lab_title = cell.contentView.viewWithTag(12) as! UILabel
                
                leftView?.backgroundColor = UIColor.redColor()
                lab_title.text = "当前加入的主办方"
                lab_title.textColor = UIColor.blackColor()
                
                return cell
                
            } else {
                
                let cell = tableView.dequeueReusableCellWithIdentifier("YSOrganizationJoinedTopCell", forIndexPath: indexPath) 
                
                if lst_org_current == nil || lst_org_current.count < 1 {
                    return cell
                }
                
                let organization = lst_org_current[indexPath.row-1]
                let img_avatar = cell.contentView.viewWithTag(11) as! UIImageView
                let lab_name = cell.contentView.viewWithTag(12) as! UILabel
                let lab_intro = cell.contentView.viewWithTag(13) as! UILabel
                let lab_tel = cell.contentView.viewWithTag(14) as! UILabel
                
                img_avatar.image = feiOSHttpImage.asyncHttpImageInUIThread(organization.institution_logo, defaultImageName:DEFAULT_IMAGE_NAME_RECTANGLE, finishCallbackInUIThread: {
                    [weak self] (handler: FEiOSHttpImageHandler) -> Void in
                    if self == nil { return }
                    img_avatar.image = self!.feiOSHttpImage.loadImageInCache(organization.institution_logo).0
                    })
                lab_name.text = organization.institution_name
                lab_intro.text = organization.introduction
                lab_tel.text = organization.phone
                
                return cell
            }
            
        } else {
            
            if indexPath.row == 0 {
                
                let cell = tableView.dequeueReusableCellWithIdentifier("YSOrganizationJoinedTitleCell", forIndexPath: indexPath)
                
                cell.backgroundColor = UIColor.clearColor()
                cell.contentView.backgroundColor = UIColor.clearColor()
                
                let leftView = cell.contentView.viewWithTag(11)
                let lab_title = cell.contentView.viewWithTag(12) as! UILabel
                
                leftView?.backgroundColor = UIColor.darkGrayColor()
                lab_title.text = "曾经加入的主办方"
                lab_title.textColor = UIColor.darkGrayColor()
                
                return cell
                
            } else {
                
                let cell = tableView.dequeueReusableCellWithIdentifier("YSOrganizationJoinedNormalCell", forIndexPath: indexPath)
                
                if lst_org_joined == nil || lst_org_joined.count < 1 {
                    return cell
                }
                
                let org_joined = lst_org_joined[indexPath.row - 1]
                let img_logo = cell.contentView.viewWithTag(11) as! UIImageView
                let lab_name = cell.contentView.viewWithTag(12) as! UILabel
                let lab_time = cell.contentView.viewWithTag(13) as! UILabel
                let top_view = cell.contentView.viewWithTag(10)
                
                if indexPath.row > 1 {
                    top_view?.hidden = true
                }
                

                img_logo.image = feiOSHttpImage.asyncHttpImageInUIThread(org_joined.institution_logo, defaultImageName:DEFAULT_IMAGE_NAME_RECTANGLE, finishCallbackInUIThread: {
                    [weak self] (handler: FEiOSHttpImageHandler) -> Void in
                    if self == nil { return }
                    img_logo.image = self!.feiOSHttpImage.loadImageInCache(org_joined.institution_logo).0
                    })
                lab_name.text = org_joined.institution_name
                lab_time.text = "加入时间：" + org_joined.update_time
                
                return cell
            }
        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        if indexPath.section == 1 && indexPath.row > 0{
            print("点击主办方", terminator: "")
        }
    }
    
    // MARK: - Actions
    
    func exitOrganization() {
        
        if lst_org_current == nil || lst_org_current.count < 1 {
            return
        }
        
        let org = lst_org_current[0]
        if org.iid == nil {
            return
        }
        
        YSTutor.exitOrganization(org.iid, block: { [weak self] (errorMsg: String!) -> Void in
            
            if self == nil {
                return
            }
            
            if errorMsg != nil {
                self!.tips.showTipsInMainThread(Text: errorMsg)
                return
            }
            
            
            if self!.lst_org_joined == nil {
                self!.lst_org_joined = [YSOrganization]()
            }
            
            self!.lst_org_joined.insert(org, atIndex: 0)
            self!.lst_org_current.removeLast()
            self!.tableView.reloadData()
        })
    }
}

//
//  YSCompetionStudentViewController.swift
//  YISAI
//
//  Created by 周超创 on 16/9/7.
//  Copyright © 2016年 Shenzhen Jianbo Information Technology Co., Ltd. All rights reserved.
//

import UIKit

class YSCompetionStudentViewController: UIViewController, UITableViewDataSource,UITableViewDelegate {
    
    var table:UITableView!
   
    var cpid: String!
    var tips: FETips = FETips()
    
    var application_fee: String!
    var benefit_price: String!
    var real_price: String!
    
    
    var lst_student: [YSStudentCompetitionInfo]!
    var feiOSHttpImage: FEiOSHttpImage = FEiOSHttpImage()
    var match_name: String!
    var competition_type: String! // 标识赛事类型，0为线上赛事，1为线下赛事
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.title = "参赛学生"
        let rect  = self.view.frame
       // rect.origin.y += 65
        table = UITableView(frame: rect)
        table.registerClass(TableViewCell.self, forCellReuseIdentifier: "cell")
        
        table.backgroundColor = UIColor.init(red: 247/255, green: 247/255, blue: 247/255, alpha: 1)
        
        table.separatorStyle = UITableViewCellSeparatorStyle.None;
        
        self.view.addSubview(table)
        
        table.delegate = self
        table.dataSource = self
        
        fetchConfirmInfo()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "fetchConfirmInfo", name: "UpdateStudentList" , object: nil)

    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        NSNotificationCenter.defaultCenter().removeObserver(self, name: "UpdateStudentList", object: nil)
  
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    func fetchConfirmInfo() {
        
        if cpid == nil {
            return
        }
        
        tips.showActivityIndicatorViewInMainThread(self, text: nil)
        
        YSCompetition.getstudentlist(cpid, resp: { [weak self] (resp_confirmInfo: [YSStudentCompetitionInfo]!, errorMsg: String!) -> Void in
            
            if self == nil {
                return
            }
            
            self!.tips.disappearActivityIndicatorViewInMainThread()
            
            if errorMsg != nil {
                self!.tips.showTipsInMainThread(Text: errorMsg)
                return
            }
            
            
            self!.lst_student = resp_confirmInfo
            
            self!.table.reloadData()
            
            
        })
    }
    
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 78
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if( lst_student == nil)
        {
            return 1
        }
        else
        {
            return lst_student.count+1
        }
        
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
    
        
        let str:String = "cell"
        
        var cell:TableViewCell = tableView.dequeueReusableCellWithIdentifier(str, forIndexPath: indexPath) as! TableViewCell
        
        
        if(indexPath.row == 0)
        {
            cell.bgview.hidden = true
            
            let left = SCREEN_WIDTH/2
            
            let button =  UIButton(type:.Custom)
            button.frame=CGRectMake(left-75, 19, 150, 40)
            button.setTitle("新增参赛学生", forState:UIControlState.Normal) //普通状态下的文字
            button.setTitleColor(UIColor.whiteColor(),forState: .Normal) //普通状态下文字的颜色
            button.setTitleColor(UIColor.grayColor(),forState: .Highlighted) //普通状态下文字的颜色
            button.setImage(UIImage(named: "com_add") , forState: .Normal)
            
            button.backgroundColor = UIColor.init(red: 239/255, green: 97/255, blue: 80/255, alpha: 1)
            button.layer.cornerRadius = 20
            button.addTarget(self,action:#selector(tapped),forControlEvents:.TouchUpInside)
            
            button.imageEdgeInsets =   UIEdgeInsetsMake(10, 10, 10, 120)
            button.titleEdgeInsets = UIEdgeInsetsMake(0, 5, 0, 0)
            
            //  button.buttonType = UIButtonType.RoundedRect
            cell.contentView.addSubview(button)
            cell.selectionStyle =  UITableViewCellSelectionStyle.None
            
            return cell
        }
        else
        {
            
        
        if lst_student == nil {
            return cell
        }
        
        let rankInfo = lst_student[indexPath.row-1]
        
        if cell.isEqual(nil) {
            cell = TableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: str)
        }
        cell.name.text = "参赛者:" + rankInfo.realname
        
        if rankInfo.videoname == nil
        {
            cell.product.text = "参赛作品:"
        }
        else
        {
            cell.product.text = "参赛作品:" + rankInfo.videoname
        }
        if rankInfo.groupname == nil
        {
            cell.group.text = "参赛组别:"
        }
        else
        {
            cell.group.text = "参赛组别:" + rankInfo.groupname
        }

            // 线下赛事
            if self.competition_type == nil || self.competition_type == "1" {
             
                if rankInfo.user_competing_process == 4
                {
                  cell.right_img.image = UIImage(named: "com_sucess")
                }
                else
                {
                    cell.right_img.image = UIImage(named: "com_pay")
                    cell.accessoryType=UITableViewCellAccessoryType.DisclosureIndicator;
                }
                
            }
            else
            {
                if(rankInfo.user_competing_process == 1)
                {
                    cell.right_img.image = UIImage(named: "com_upload")
                    cell.accessoryType=UITableViewCellAccessoryType.DisclosureIndicator;
                    
                    
                }
                else if(rankInfo.user_competing_process == 3)
                {
                    if(rankInfo.user_upload_status == 0)
                    {
                        cell.right_img.image = UIImage(named: "com_upload")
                        cell.accessoryType=UITableViewCellAccessoryType.DisclosureIndicator;
                    }
                    else
                    {
                        cell.right_img.image = UIImage(named: "com_pay")
                        cell.accessoryType=UITableViewCellAccessoryType.DisclosureIndicator;
                    }
                }else
                {
                    cell.right_img.image = UIImage(named: "com_sucess")
                }
            }
            
            
            if rankInfo.avatar == nil || rankInfo.avatar.isEmpty {
                 cell.left_img.image = UIImage(named: "com_deflaut")
            }
            else
            {
                cell.left_img.image = feiOSHttpImage.asyncHttpImageInUIThread(rankInfo.avatar, defaultImageName:DEFAULT_AVATAR, finishCallbackInUIThread: {
                    [weak self] (handler: FEiOSHttpImageHandler) -> Void in
                    if self == nil { return }
                    cell.left_img.image = self!.feiOSHttpImage.loadImageInCache(rankInfo.avatar).0
                    })
                
            }
        cell.selectionStyle =  UITableViewCellSelectionStyle.None
            
        return cell
            
            }
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if(indexPath.row != 0)
        {
            
            if lst_student == nil {
                return
            }
            
            let rankInfo = lst_student[indexPath.row-1]
            
            
            let crid = rankInfo.crid
        
        
        // 线下赛事
        if self.competition_type == nil || self.competition_type == "1" {
            if rankInfo.user_competing_process == 4
            {
                return
            }
            else
            {
                gotoPay(crid)
                
            }
        }
        else
        {
            
            
            if(rankInfo.user_competing_process == 1)
            {
                gotoPublish(crid)
                
            }
            else if(rankInfo.user_competing_process == 3)
            {
                if(rankInfo.user_upload_status == 0)
                {
                    gotoPublish(crid)
                }
                else
                {
                    gotoPay(crid)
                }
            }
         }
        }
    }
    
    func tapped()
    {
        
        let controller = YSCompetitionConditonViewController()
        controller.cpid = cpid
        controller.competition_type = competition_type
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    func gotoPublish(crid:String) {
        
     /*   if competitionDetail == nil || competitionDetail.cpid == nil {
            return
        }
        */
        let controller = YSCameraViewController()
      //  controller.matchName = competitionDetail.match_name
        controller.cpid = self.cpid
        controller.type = .Competition
        controller.crid = crid
        controller.competition_type = self.competition_type
       // let navController = UINavigationController(rootViewController: controller)
        
      //  ysApplication.tabbarController.presentViewController(navController, animated: true, completion: nil)
        
      //  self.navigationController?.popToRootViewControllerAnimated(false)
        
        
        let transition = CATransition()
        transition.duration = 0.3
        transition.timingFunction = CAMediaTimingFunction.init(name: kCAMediaTimingFunctionEaseInEaseOut)
        transition.type = kCATransitionMoveIn;
        transition.subtype = kCATransitionFromRight;
        
        
        
        self.navigationController!.view.layer.addAnimation(transition, forKey: nil)
        
        controller.hidesBottomBarWhenPushed = true
        
        self.navigationController?.navigationBarHidden = true
        
        self.navigationController!.pushViewController(controller, animated: false)
        
    }
    
    func gotoPay(crid:String) {
        
        /*if competitionDetail == nil || competitionDetail.cpid == nil {
            return
        }
        */
        
        
        let controller = YSPulishPayViewController()
       // controller.cpid = self.cpid
        controller.crid = crid
        controller.match_name = self.match_name
        controller.application_fee = self.application_fee
        controller.benefit_price = self.benefit_price
        controller.real_price = self.real_price
        controller.competition_type = self.competition_type
        
        self.navigationController?.pushViewController(controller, animated: true)
 
        
    }
    

    
}

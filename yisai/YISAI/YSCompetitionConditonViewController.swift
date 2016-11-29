//
//  YSCompetitionConditonViewController.swift
//  YISAI
//
//  Created by 周超创 on 16/8/4.
//  Copyright © 2016年 Shenzhen Jianbo Information Technology Co., Ltd. All rights reserved.
//

import UIKit

class YSCompetitionConditonViewController: UIViewController,UITableViewDataSource,UITableViewDelegate, YSCustomDatePickerDelegate,UITextFieldDelegate {
    
    
    var dataTable:UITableView!;
    //var screenObject = UIScreen.mainScreen().bounds;
    var itemString=["姓名：","联系电话：","出生日期：","身份证号：","证书邮寄：","指导老师：","老师手机：","就学机构"]
    
    var txf_Name: UITextField!
    var txf_BounDate: UILabel!
    var txf_Cardid: UITextField!
    var txf_Cellphone: UITextField!
    var txf_address: UITextField!
    var txf_tchName: UITextField!
    var txf_tchphone: UITextField!
    var txf_school: UITextField!
  
    var competition_type: String!
    
    var lab_selectTeam: UILabel!
    
    var pickerController: YSCustomDatePickerViewController!
    
    var confirmInfo: YSCompetitionConfirmInfo!
    var tips: FETips = FETips()
    var crid: String!
    var cpid: String!
    var cgid: String!
    
    var isConfirm: Bool = false
    
    //var textField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
         tips.duration = 1
        
        
        
        self.view.backgroundColor =  UIColor.init(red: 247/255, green: 247/255, blue: 247/255, alpha: 1)
        self.title = "参赛信息"
        let org_x:CGFloat = 0
        let org_y:CGFloat = 0
        let org_h:CGFloat = SCREEN_HEIGHT-140
        
        
        dataTable = UITableView(frame: CGRectMake(org_x, org_y, SCREEN_WIDTH, org_h),style:UITableViewStyle.Grouped)
        dataTable.dataSource = self
        dataTable.delegate  = self
        //dataTable.scrollEnabled = false
        dataTable.backgroundColor = UIColor.init(red: 247/255, green: 247/255, blue: 247/255, alpha: 1)
        
        self.view.addSubview(dataTable);
        
        let button =  UIButton(type:.Custom)
        button.frame=CGRectMake(15, SCREEN_HEIGHT-140, SCREEN_WIDTH-30, 43)
        if competition_type == "0"
        {
            button.setTitle("上传参赛视频", forState:UIControlState.Normal) //普通状态下的文字
        }
        else
        {
            button.setTitle("提交", forState:UIControlState.Normal) //普通状态下的文字
        }
        
        button.setTitleColor(UIColor.whiteColor(),forState: .Normal) //普通状态下文字的颜色
        button.setTitleColor(UIColor.grayColor(),forState: .Highlighted) //普通状态下文字的颜色
        button.backgroundColor = UIColor.init(red: 239/255, green: 97/255, blue: 80/255, alpha: 1)
        button.layer.cornerRadius = 5
        button.addTarget(self,action:#selector(tapped),forControlEvents:.TouchUpInside)
        
        
        //  button.buttonType = UIButtonType.RoundedRect
        self.view.addSubview(button)
        
        
        
        fetchConfirmInfo()
        
        pickerController = UIStoryboard(name: "YSCustom", bundle: nil).instantiateViewControllerWithIdentifier("YSCustomDatePickerViewController") as! YSCustomDatePickerViewController
        pickerController.delegate = self
        self.view.addSubview(pickerController.view)
        
      //  payController = UIStoryboard(name: "YSCustom", bundle: nil).instantiateViewControllerWithIdentifier("YSCustomPayViewController") as! YSCustomPayViewController
       // payController.delegate = self
       // self.view.addSubview(payController.view)
        
        
   
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
        
        YSCompetition.getConfirmDetail(cpid, resp: { [weak self] (resp_confirmInfo: YSCompetitionConfirmInfo!, errorMsg: String!) -> Void in
            
            if self == nil {
                return
            }
            
            self!.tips.disappearActivityIndicatorViewInMainThread()
            
            if errorMsg != nil {
                self!.tips.showTipsInMainThread(Text: errorMsg)
                return
            }
            
            self!.confirmInfo = resp_confirmInfo
            self!.configureData()
           // self!.tableView.reloadData()
            })
    }

    func configureData() {
        
        if confirmInfo == nil {
            return
        }
        
        
        if(ysApplication.loginUser == "1")
        {
            
            txf_Name.text = ysApplication.loginUser.realName
            txf_BounDate.text = ysApplication.loginUser.birth
            txf_Cardid.text = ysApplication.loginUser.idCard
            txf_Cellphone.text = ysApplication.loginUser.tel
            txf_address.text = ysApplication.loginUser.region
            txf_school.text = ysApplication.loginUser.institution
        }
    }
    
    func tapped(){
        if confirmInfo == nil {
            return
        }
        
        // 用户配置(我要报名)
        let conf = ysApplication.loginUser.conf
        if conf != nil {
            let competition_participate = conf["competition_participate"] as? Int
            if competition_participate != nil {
                if competition_participate! == 0 {
                    tips.showTipsInMainThread(Text: "赛事暂停报名")
                    return
                }
            }
        }
        
        if checkInputEmpty(txf_Name.text)  {
            tips.showTipsInMainThread(Text: "请填写姓名")
            return
        }

        
        if checkInputEmpty(txf_Cellphone.text)  {
            tips.showTipsInMainThread(Text: "请填写电话号码")
            return
        }
        
        if !isTelNumber(txf_Cellphone.text!)
        {
            tips.showTipsInMainThread(Text: "请填写正确的电话号码")
            return
            
        }
        
        if checkInputEmpty(txf_BounDate.text)  {
            tips.showTipsInMainThread(Text: "请填写生日信息")
            return
        }
        if txf_BounDate.text == "请输入出生日期(必填)"  {
            tips.showTipsInMainThread(Text: "请填写生日信息")
            return
        }
        
        if checkInputEmpty(txf_Cardid.text)  {
            tips.showTipsInMainThread(Text: "请填写身份证信息")
            return
        }
        
       // if validateIdentityCard(txf_Cardid.text!)
       // {
         //   tips.showTipsInMainThread(Text: "请填写正确的身份证信息")
           // return
       // }

        
        if cgid == nil && (confirmInfo.lst_competition_group != nil && confirmInfo.lst_competition_group.count > 0) {
            tips.showTipsInMainThread(Text: "请选择组别")
            return
        }
        
        if checkInputEmpty(txf_address.text) {
            tips.showTipsInMainThread(Text: "请填写联系地址")
            return
        }
        
        if isConfirm {
            tips.showTipsInMainThread(Text: "正在提交报名信息")
            return
        }

        isConfirm = true

        let analyticsVersion = NSBundle.mainBundle().infoDictionary!["CFBundleShortVersionString"] as! String
        
       // let cid  =  confirmInfo.obj_child_info.cid as String
        
        YSCompetition.confirmRegistration(cpid, cgid: cgid, realname: txf_Name.text!, phone: txf_Cellphone.text!, birth: txf_BounDate.text!, identity_card: txf_Cardid.text!, region: txf_address.text!, institution: txf_school.text,tch_name: txf_tchName.text!,tch_phone: txf_tchphone.text!,version: analyticsVersion) { [weak self] (resp_crid: String!, errorMsg: String!) -> Void in
            
            if self == nil {
                return
            }
            
            self!.isConfirm = false
            
            if errorMsg != nil {
                
                self!.tips.showTipsInMainThread(Text: errorMsg)
                return
            }
            
            if !checkInputEmpty(self!.txf_Name.text) {
                ysApplication.loginUser.setUserRealName(self!.txf_Name.text!)
            }
            if !checkInputEmpty(self!.txf_BounDate.text) {
                ysApplication.loginUser.setUserBirth(self!.txf_BounDate.text!)
            }
            if !checkInputEmpty(self!.txf_Cellphone.text) {
                ysApplication.loginUser.setUserTel(self!.txf_Cellphone.text!)
            }
            if !checkInputEmpty(self!.txf_Cardid.text) {
                ysApplication.loginUser.setUserIDCard(self!.txf_Cardid.text!)
            }
            if !checkInputEmpty(self!.txf_address.text) {
                ysApplication.loginUser.setUserRegion(self!.txf_address.text!)
            }
            if !checkInputEmpty(self!.txf_school.text) {
                ysApplication.loginUser.setUserInstitution(self!.txf_school.text!)
            }
            
            if self!.confirmInfo.application_fee != nil && (self!.confirmInfo.application_fee as NSString).floatValue > 0.0 {
                
                // 赛事报名收费点击
                MobClick.event("join_competition", attributes: ["fee_type": "charge"])
                
            } else {
                
                // 赛事报名免费点击
                MobClick.event("join_competition", attributes: ["fee_type": "free"])
            }
            
            self!.crid = resp_crid
            
           // if self!.confirmInfo.application_fee != nil && (self!.confirmInfo.application_fee as NSString).floatValue > 0.0 {
                
              //  self!.payController.showPayView()
          //  } else {
                
                // 参赛状态更改
                YSBudge.setEnterCompetition("1")
                
                self!.tips.showTipsInMainThread(Text: "报名成功")
            
            NSNotificationCenter.defaultCenter().postNotificationName("UpdateStudentList", object: nil, userInfo: nil)
            
                if self!.tabBarController != nil {
                    self!.tabBarController?.tabBar.showBadgeOnItemIndex(2)
                }
                
                fe_std_data_set_json("http_post_cache", key: "competitionInfo" + "detail" + self!.cpid + ysApplication.loginUser.uid, jsonValue: nil, expire_sec: DEFAULT_EXPIRE_SEC)
                
                self!.resetCompetitionProgress()
                
                if self!.competition_type == nil || self!.competition_type == "1" {
                    // 线下赛事
                    if self!.confirmInfo.application_fee != nil && (self!.confirmInfo.application_fee as NSString).floatValue > 0.0 {
                        
                        // 线下赛事收费
                        
                        let controller = YSPulishPayViewController()
                        controller.crid = self!.crid
                        controller.match_name = self!.confirmInfo.match_name
                        controller.application_fee = self!.confirmInfo.application_fee
                        controller.benefit_price = self!.confirmInfo.benefit_price
                        controller.competition_type = self!.competition_type
                        controller.real_price =  self!.confirmInfo.application_fee
                        
                        
                        
                        if  ysApplication.loginUser.role_type != "1"
                        {
                            controller.application_fee = self!.confirmInfo.pay_amount
                        }
                        
                        
                        self!.navigationController?.pushViewController(controller, animated: true)
                    
                        
                    } else {
                        delayCall(1.0, block: { () -> Void in
                            self!.navigationController?.popToRootViewControllerAnimated(false)
                        })
                    }
                   
                    
                    return
                }
                
                self!.gotoPublish()
           // }
            
        }
        
    }
    
    func resetCompetitionProgress() {
        
        if self.navigationController?.childViewControllers.count >= 2 {
            
            let controller = self.navigationController?.childViewControllers[self.navigationController!.childViewControllers.count - 2] as? YSCompetitionDetailViewController
            
            if controller != nil {
                // 切换报名状态，报名成功
                controller!.competitionDetail.user_competing_process = 1
            }
        }
    }
    
    func gotoPublish() {
        
        delayCall(1.0, block: { () -> Void in
            // 跳转到发布编辑页
            /*let controller = UIStoryboard(name: "YSPublish", bundle: nil).instantiateViewControllerWithIdentifier("YSPublishViewController") as! YSPublishViewController
            controller.type = .Competition
            controller.cpid = self.confirmInfo.cpid
            controller.crid = self.crid
            controller.matchName = self.confirmInfo.match_name
            controller.cid = self.confirmInfo.obj_child_info.cid
            */
            
            let controller = YSCameraViewController()
            controller.type = .Competition
            controller.cpid = self.confirmInfo.cpid
            controller.crid = self.crid
            controller.matchName = self.confirmInfo.match_name
            controller.competition_type = self.competition_type
            
            
            let transition = CATransition()
            transition.duration = 0.3
            transition.timingFunction = CAMediaTimingFunction.init(name: kCAMediaTimingFunctionEaseInEaseOut)
            transition.type = kCATransitionMoveIn;
            transition.subtype = kCATransitionFromRight;
            
            
            
            self.navigationController!.view.layer.addAnimation(transition, forKey: nil)
            
            controller.hidesBottomBarWhenPushed = true
            
            self.navigationController?.navigationBarHidden = true
            
            self.navigationController!.pushViewController(controller, animated: false)
            
        })
    }

    //1.1默认返回一组
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2;
    }
    
    // 1.2 返回行数
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(section == 0){
            return 8;
        }else{
            return 1;
        }
    }
    
    //1.3 返回行高
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat{
        
        if(indexPath.section == 0){
            return 50;
        }else{
            return 50;
            
        }
    }
    
    //1.4每组的头部高度
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 10;
    }
    
    //1.5每组的底部高度
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 1;
    }
    //1.6 返回数据源
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let identifier="studentidenttifier";
        
        var cell=tableView.dequeueReusableCellWithIdentifier(identifier);
        if(cell == nil){
            cell=UITableViewCell(style: UITableViewCellStyle.Value1, reuseIdentifier: identifier);
        }
        else
        {
            
            while(cell?.contentView.subviews.last != nil){
                cell?.contentView.subviews.last?.removeFromSuperview()
            }
        }
    
        if(indexPath.section == 0){
          
            //cell?.textLabel?.text= itemString[indexPath.row];
            
            let  title_str = UILabel(frame: CGRectMake(15,10,185,30))
            //设置边框样式为圆角矩形
            //  txf_BounDate.borderStyle = UITextBorderStyle.None
            // txf_BounDate.placeholder="请输入出生日期(必填)"
            title_str.textColor = UIColor.blackColor()
            title_str.textAlignment = NSTextAlignment.Left
            title_str.text = itemString[indexPath.row];
            
            cell?.contentView.addSubview(title_str)
          //  let textField =
          
            
            switch indexPath.row {
            case 0:
                
                if(txf_Name  == nil)
                {
                txf_Name = UITextField(frame: CGRectMake(100,10,200,30))
                //设置边框样式为圆角矩形
                txf_Name.borderStyle = UITextBorderStyle.None
                txf_Name.placeholder="请输入参赛者姓名(必填)"
                cell?.contentView.addSubview(txf_Name)
      
                 txf_Name.inputAccessoryView =  addCanel()
                }
                else
                {
                    cell?.contentView.addSubview(txf_Name)
                }
                break;
            case 1:
                if(txf_Cellphone == nil)
                {
                txf_Cellphone = UITextField(frame: CGRectMake(100,10,200,30))
                //设置边框样式为圆角矩形
                txf_Cellphone.borderStyle = UITextBorderStyle.None
                txf_Cellphone.placeholder = "请输入手机号码(必填)"
                cell?.contentView.addSubview(txf_Cellphone)
                txf_Cellphone.keyboardType = UIKeyboardType.NumberPad
                txf_Cellphone.inputAccessoryView =  addCanel()
                txf_Cellphone.delegate = self
                txf_Cellphone.tag = 1
                }
                else{
                       cell?.contentView.addSubview(txf_Cellphone)
                }
                break;
                
            case 2:
                if(txf_BounDate == nil)
                {
                    txf_BounDate = UILabel(frame: CGRectMake(100,10,200,30))
                    //设置边框样式为圆角矩形
                    //  txf_BounDate.borderStyle = UITextBorderStyle.None
                    // txf_BounDate.placeholder="请输入出生日期(必填)"
                    txf_BounDate.textColor = UIColor.grayColor()
                    txf_BounDate.textAlignment = NSTextAlignment.Left
                    txf_BounDate.text = "请输入出生日期(必填)"
                    
                    cell?.contentView.addSubview(txf_BounDate)
                }
                else
                {
                    cell?.contentView.addSubview(txf_BounDate)
                }
                break;
                

            case 3:
                if( txf_Cardid == nil)
                {
                txf_Cardid = UITextField(frame: CGRectMake(100,10,200,30))
                //设置边框样式为圆角矩形
                txf_Cardid.borderStyle = UITextBorderStyle.None
                txf_Cardid.placeholder="请输入身份证号(必填)"
                cell?.contentView.addSubview(txf_Cardid)
                //txf_Cardid.keyboardType = UIKeyboardType.DecimalPad
                txf_Cardid.inputAccessoryView =  addCanel()
                }
                else
                {
                    cell?.contentView.addSubview(txf_Cardid)
                }
                break;
                

            case 4:
                
                if(txf_address == nil)
                {
                    txf_address = UITextField(frame: CGRectMake(100,10,200,30))
                    //设置边框样式为圆角矩形
                    txf_address.borderStyle = UITextBorderStyle.None
                    txf_address.placeholder = "请输入地址(必填)"
                    cell?.contentView.addSubview(txf_address)
                    
                    txf_address.inputAccessoryView =  addCanel()
                }
                else
                {
                    cell?.contentView.addSubview(txf_address)
                }
                
                
                break;
            case 5:
                if(txf_tchName == nil)
                {
                    txf_tchName = UITextField(frame: CGRectMake(100,10,200,30))
                    //设置边框样式为圆角矩形
                    txf_tchName.borderStyle = UITextBorderStyle.None
                    txf_tchName.placeholder="请输入指导老师姓名"
                    cell?.contentView.addSubview(txf_tchName)
                    
                    txf_tchName.inputAccessoryView =  addCanel()
                    txf_tchName.delegate = self
                }
                else
                {
                    cell?.contentView.addSubview(txf_tchName)
                }
                break;
            case 6:
                if(txf_tchphone == nil)
                {
                    txf_tchphone = UITextField(frame: CGRectMake(100,10,200,30))
                    //设置边框样式为圆角矩形
                    txf_tchphone.borderStyle = UITextBorderStyle.None
                    txf_tchphone.placeholder="请输入指导老师电话"
                    cell?.contentView.addSubview(txf_tchphone)
                    txf_tchphone.inputAccessoryView =  addCanel()
                    txf_tchphone.keyboardType = UIKeyboardType.NumberPad
                    txf_tchphone.inputAccessoryView =  addCanel()
                    txf_tchphone.delegate = self
                }
                else
                {
                    cell?.contentView.addSubview(txf_tchphone)
                }
                break;
                
            default:
                
                if(txf_school == nil)
                {
                txf_school = UITextField(frame: CGRectMake(100,10,200,30))
                //设置边框样式为圆角矩形
                txf_school.borderStyle = UITextBorderStyle.None
                txf_school.placeholder="请请输入就学机构"
                cell?.contentView.addSubview(txf_school)
                
                txf_school.delegate = self
                
                 txf_school.inputAccessoryView =  addCanel()
                }
                else
                {
                    cell?.contentView.addSubview(txf_school)
                }
                
                
                break;
            }
            
        }else{
          //  cell?.textLabel?.text="参赛组别";
            
            
            let  title_str = UILabel(frame: CGRectMake(15,10,185,30))
            //设置边框样式为圆角矩形
            //  txf_BounDate.borderStyle = UITextBorderStyle.None
            // txf_BounDate.placeholder="请输入出生日期(必填)"
            title_str.textColor = UIColor.blackColor()
            title_str.textAlignment = NSTextAlignment.Left
            title_str.text = "参赛组别";
            
            cell?.contentView.addSubview(title_str)
            
            
            let wid:CGFloat = SCREEN_WIDTH - 140
            
            lab_selectTeam = UILabel(frame: CGRectMake(100,10,wid,30))
            lab_selectTeam.textAlignment  = NSTextAlignment.Left
             cell?.contentView.addSubview(lab_selectTeam)
            
            cell?.accessoryType=UITableViewCellAccessoryType.DisclosureIndicator;
            
            
            
        }
        
        cell?.backgroundColor = UIColor.whiteColor()
        cell?.selectionStyle =  UITableViewCellSelectionStyle.None
        
          //cell?.contentView.backgroundColor = UIColor.whiteColor()
        
        // hotCell!.contentView.addSubview(btn_hot)
        return cell!;
    }
    
    
    
     func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        //print(indexPath.section)
        // print(indexPath.row)
        if indexPath.section == 1 && indexPath.row == 0 {
            // 选择组别
            resignAllResponder()
            
            if confirmInfo.lst_competition_group.count > 0{
                let alertController = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.ActionSheet)
                
                for group in confirmInfo.lst_competition_group {
                    let alertAction = UIAlertAction(title: group.title, style: UIAlertActionStyle.Default, handler: { [weak self] (action: UIAlertAction!) -> Void in
                        
                        if self == nil {
                            return
                        }
                        
                        self!.cgid = group.cgid
                        self!.lab_selectTeam.text = group.title
                        })
                    alertController.addAction(alertAction)
                }
                
                
                
                let cancelAction = UIAlertAction(title: "取消", style: UIAlertActionStyle.Cancel, handler: nil)
                alertController.addAction(cancelAction)
                
                if isUsingiPad() {
                    
                    alertController.popoverPresentationController?.sourceView = self.view
                   // alertController.popoverPresentationController?.sourceRect = self.view.frame
                }
               
                presentViewController(alertController, animated: true, completion: nil)
            }
            
        }
        else if indexPath.section == 0 && indexPath.row == 2 {
            // 选择出生日期
            resignAllResponder()
            
            pickerController.showPicker()
        }
    }
    
    func  resignAllResponder()
    {
     
        //txf_name.resignFirstResponder()
        txf_Cardid.resignFirstResponder()
        
        txf_Name.resignFirstResponder()
        //txf_Name.resignFirstResponder()
 
        txf_Cellphone.resignFirstResponder()
        txf_tchName.resignFirstResponder()
        txf_tchphone.resignFirstResponder()
        txf_school.resignFirstResponder()
        txf_address.resignFirstResponder()
    }
    
    /**
     
     解决textField遮挡键盘代码
     :param: textField textField description
     */
    func textFieldDidBeginEditing(textField: UITextField) {
        //
        
        if textField.tag != 1
        {
        let frame:CGRect = textField.frame
        let offset:CGFloat = frame.origin.y + 700 - (self.view.frame.size.height)
        
        if offset > 0  {
            
            self.view.frame = CGRectMake(0.0, -offset, self.view.frame.size.width, self.view.frame.size.height)
        }
        }
    }
    
    /**
     恢复视图
     
     :param: textField textField description
     */
    func textFieldDidEndEditing(textField: UITextField) {
        //
        self.view.frame = CGRectMake(0, 60, self.view.frame.size.width, self.view.frame.size.height)
        
        if textField.tag == 1
        {
            let text:NSMutableString = textField.text!.mutableCopy() as! NSMutableString
            
            if text.length == 11
            {
                if isTelNumber(text)
                {
                    //
                    
                    YSCompetition.getStudentInfo(text as String, resp: { [weak self] (resp_confirmInfo: YSStudentInfo!, errorMsg: String!) -> Void in                        if self == nil {
                            return
                        }
                        
                        self!.tips.disappearActivityIndicatorViewInMainThread()
                        
                        if errorMsg != nil {
                            self!.tips.showTipsInMainThread(Text: errorMsg)
                            return
                        }
                        
                        self!.txf_address.text = resp_confirmInfo.region
                        self!.txf_Cardid.text = resp_confirmInfo.identity_card
                        self!.txf_school.text =  resp_confirmInfo.school_institution
                        self!.txf_BounDate.text = resp_confirmInfo.birth
                    })
                    
                }
            }
        }
        
        
        
    }
    
    // MARK: - YSCustomPickerViewDelegate
    
    func changeDateString(dateString: String) {
        
        txf_BounDate.text = dateString
        
      //  self.tableView.reloadData()
    }
    
    func addCanel()->UIToolbar
    {
        let toolBar = UIToolbar()
        toolBar.barStyle = UIBarStyle.Default
        toolBar.frame = CGRectMake(0,0,SCREEN_WIDTH,40)
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: nil, action: nil)
        
        let button =  UIButton(type:.Custom)
        button.frame=CGRectMake(2, 2, 50, 30)
        button.setTitle("完成", forState:UIControlState.Normal) //普通状态下的文字
        button.setTitleColor(UIColor.whiteColor(),forState: .Normal) //普通状态下文字的颜色
        button.backgroundColor = UIColor.redColor()
        button.layer.cornerRadius = 5
        button.addTarget(self,action:#selector(resignAllResponder),forControlEvents:.TouchUpInside)
        
        
        //继续创建按钮
        // let doneButton = UIBarButtonItem(title: "完成", style:UIBarButtonItemStyle.Plain, target:self, action:#selector(resignInput))
        
        let doneButton  = UIBarButtonItem(customView: button)
        
        
        
        toolBar.setItems([spaceButton, doneButton], animated: false)
        
        
       return toolBar

    }
    
    func isTelNumber(num:NSString)->Bool
    {
        let mobile = "^1(3[0-9]|5[0-35-9]|8[025-9])\\d{8}$"
        let  CM = "^1(34[0-8]|(3[5-9]|5[017-9]|8[278])\\d)\\d{7}$"
        let  CU = "^1(3[0-2]|5[256]|8[56])\\d{8}$"
        let  CT = "^1((33|53|8[09])[0-9]|349)\\d{7}$"
        let regextestmobile = NSPredicate(format: "SELF MATCHES %@",mobile)
        let regextestcm = NSPredicate(format: "SELF MATCHES %@",CM )
        let regextestcu = NSPredicate(format: "SELF MATCHES %@" ,CU)
        let regextestct = NSPredicate(format: "SELF MATCHES %@" ,CT)
        if ((regextestmobile.evaluateWithObject(num) == true)
            || (regextestcm.evaluateWithObject(num)  == true)
            || (regextestct.evaluateWithObject(num) == true)
            || (regextestcu.evaluateWithObject(num) == true))
        {
            return true
        }
        else
        {
            return false
        }
        
    }
   /* func isRealName(num:NSString)->Bool
    {
        let mobile:String  = "[a-zA-Z0-9\u4e00-\u9fa5][a-zA-Z0-9\u4e00-\u9fa5]+"
    
        let regextestmobile = NSPredicate(format: "SELF MATCHES %@",mobile)

        if (regextestmobile.evaluateWithObject(num) == true)
        {
            return true
        }
        else
        {
            return false
        }
        
    }*/
  
    func validateIdentityCard(identityCard:NSString)->Bool
    {
        let flag:Bool;
        if (identityCard.length <= 0) {
            flag = false;
            return flag;
        }
        let regex2 = "^(\\d{14}|\\d{17})(\\d|[xX])$"
        
        // letidentityCardPredicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",regex2];
        
        let regextestct = NSPredicate(format: "SELF MATCHES %@" ,regex2)
        
        
        return regextestct.evaluateWithObject(identityCard)
    }
    
    
}

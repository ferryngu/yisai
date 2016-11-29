//
//  YSCompetitionConfirmViewController.swift
//  YISAI
//
//  Created by Yufate on 15/6/25.
//  Copyright (c) 2015年 Shenzhen Jianbo Information Technology Co., Ltd. All rights reserved.
//

import UIKit

class YSCompetitionConfirmViewController: UITableViewController, UITextFieldDelegate, YSCustomDatePickerDelegate, YSCustomPayViewDelegate, WXApiDelegate {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var lab_match_name: UILabel!
    @IBOutlet weak var lab_institutuon_name: UILabel!
    @IBOutlet weak var lab_competition_date: UILabel!
    @IBOutlet weak var lab_application_fee: UILabel!
    @IBOutlet weak var txf_name: UITextField!
    @IBOutlet weak var txf_birth: UITextField!
    @IBOutlet weak var txf_tel: UITextField!
    @IBOutlet weak var txf_idNum: UITextField!
    @IBOutlet weak var lab_group: UILabel!
    @IBOutlet weak var txf_region: UITextField!
    @IBOutlet weak var txf_institution: UITextField!
    @IBOutlet weak var pageControl: UIPageControl!
    
    var cpid: String!
    var cgid: String!
    var confirmInfo: YSCompetitionConfirmInfo!
    var tips: FETips = FETips()
    var pickerController: YSCustomDatePickerViewController!
    var isConfirm: Bool = false
    var crid: String!
    var payStatus: Bool!
    var updateWrongTimes: Int = 0
    var wxpayoid: String!
    var payController: YSCustomPayViewController!
    var competition_type: String!
    
    var feiOSHttpImage: FEiOSHttpImage = FEiOSHttpImage()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()\
        tips.duration = 1
        
        fetchConfirmInfo()
        
        pickerController = UIStoryboard(name: "YSCustom", bundle: nil).instantiateViewControllerWithIdentifier("YSCustomDatePickerViewController") as! YSCustomDatePickerViewController
        pickerController.delegate = self
        self.view.addSubview(pickerController.view)
        
        payController = UIStoryboard(name: "YSCustom", bundle: nil).instantiateViewControllerWithIdentifier("YSCustomPayViewController") as! YSCustomPayViewController
        payController.delegate = self
        self.view.addSubview(payController.view)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "wechatPaySuccess:", name: YSWechatPaySuccess, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "wechatPayFailed:", name: YSWechatPayFailed, object: nil)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        NSNotificationCenter.defaultCenter().removeObserver(self, name: YSWechatPaySuccess, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: YSWechatPayFailed, object: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
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
            self!.tableView.reloadData()
        })
    }
    
    func configureData() {
        
        if confirmInfo == nil {
            return
        }
        
        for subview in scrollView.subviews {
            subview.removeFromSuperview()
        }
        
        lab_match_name.text = confirmInfo.match_name
        lab_institutuon_name.text = "主办方：\(confirmInfo.institution_name)"
        lab_competition_date.text = "报名时间：\(confirmInfo.start_time)-\(confirmInfo.last_time)"
        lab_application_fee.text = "报名费用：" + (Int(confirmInfo.payment_type) == 0 ? "免费" : "\(confirmInfo.application_fee)元/人")
        
        if confirmInfo.lst_publicity_pic != nil && confirmInfo.lst_publicity_pic.count > 0 {
            
            scrollView.contentSize = CGSize(width: SCREEN_WIDTH * CGFloat(confirmInfo.lst_publicity_pic.count), height: 0)
            pageControl.numberOfPages = confirmInfo.lst_publicity_pic.count
            
            for index in 0..<confirmInfo.lst_publicity_pic.count {
                let publicity_pic = confirmInfo.lst_publicity_pic[index]
                let img_publicity_pic = UIImageView(frame: CGRect(x: SCREEN_WIDTH * CGFloat(index), y: 0, width: SCREEN_WIDTH, height: SCREEN_WIDTH * 53 / 102))
                img_publicity_pic.image = feiOSHttpImage.asyncHttpImageInUIThread(publicity_pic, defaultImageName:DEFAULT_IMAGE_NAME_RECTANGLE, finishCallbackInUIThread: {
                    [weak self] (handler: FEiOSHttpImageHandler) -> Void in
                    
                    if self == nil {
                        return
                    }
                    
                    img_publicity_pic.image = self!.feiOSHttpImage.loadImageInCache(publicity_pic).0
                })
                img_publicity_pic.clipsToBounds = true
                img_publicity_pic.contentMode = .ScaleAspectFill
                scrollView.addSubview(img_publicity_pic)
            }
            
        }
        
//        let child_info = confirmInfo.obj_child_info
        txf_name.text = ysApplication.loginUser.realName
        txf_birth.text = ysApplication.loginUser.birth
        txf_idNum.text = ysApplication.loginUser.idCard
        txf_tel.text = ysApplication.loginUser.tel
        txf_region.text = ysApplication.loginUser.region
        txf_institution.text = ysApplication.loginUser.institution
    }
    
    func resignAllResponder() {
        txf_tel.resignFirstResponder()
        txf_name.resignFirstResponder()
        txf_idNum.resignFirstResponder()
//        txf_birth.resignFirstResponder()
    }
    
    func gotoPublish() {
        
        delayCall(1.0, block: { () -> Void in
            // 跳转到发布编辑页
           /* let controller = UIStoryboard(name: "YSPublish", bundle: nil).instantiateViewControllerWithIdentifier("YSPublishViewController") as! YSPublishViewController
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
            
            controller.hidesBottomBarWhenPushed = true
            
            
            
            let transition = CATransition()
            transition.duration = 0.3
            transition.timingFunction = CAMediaTimingFunction.init(name: kCAMediaTimingFunctionEaseInEaseOut)
            transition.type = kCATransitionMoveIn;
            transition.subtype = kCATransitionFromRight;
            
            
            
            self.navigationController!.view.layer.addAnimation(transition, forKey: nil)
            
            self.navigationController?.navigationBarHidden = true
            
            self.navigationController!.pushViewController(controller, animated: false)
            
           // let navController = UINavigationController(rootViewController: controller)
           // self.navigationController?.popToRootViewControllerAnimated(false)
            //ysApplication.tabbarController.presentViewController(navController, animated: true, completion: nil)
        })
    }
    
    // 同步微信支付状态
    func updateWXPayStatus(oid: String, result: String) {
        
        tips.showActivityIndicatorViewInMainThread("正在同步支付信息")
        YSPay.updateWXPayStatus(oid, result: result) { [weak self] (errorMsg: String!) -> Void in
            
            if self == nil {
                return
            }
            
            self!.isConfirm = false
            
            self!.tips.disappearActivityIndicatorViewInMainThread()
            
            if errorMsg != nil {
                
                self!.tips.showTipsInMainThread(Text: errorMsg)
                
                self!.updateWrongTimes++
                
                if self!.updateWrongTimes > 2 {
                    
                    let alertController = UIAlertController(title: "提示", message: "请联系易赛客服,获取技术支持！\n支付号：\(oid)", preferredStyle: UIAlertControllerStyle.Alert)
                    let cancelAction = UIAlertAction(title: "确定", style: UIAlertActionStyle.Cancel, handler: nil)
                    alertController.addAction(cancelAction)
                    
                    if isUsingiPad() {
                        
                        alertController.popoverPresentationController?.sourceView = self!.view
                        alertController.popoverPresentationController?.sourceRect = self!.view.frame
                    }
                    
                    self!.presentViewController(alertController, animated: true, completion: nil)
                    return
                } else {
                    
                    let alertController = UIAlertController(title: "提示", message: "支付信息同步失败", preferredStyle: UIAlertControllerStyle.Alert)
                    let confirmAction = UIAlertAction(title: "再次同步", style: UIAlertActionStyle.Default, handler: { (action: UIAlertAction) -> Void in
                        self!.updateWXPayStatus(oid, result: result)
                    })
                    
                    alertController.addAction(confirmAction)
                    
                    if isUsingiPad() {
                        
                        alertController.popoverPresentationController?.sourceView = self!.view
                        alertController.popoverPresentationController?.sourceRect = self!.view.frame
                    }
                    
                    self!.presentViewController(alertController, animated: true, completion: nil)
                }
                return
            }
            
//            self!.tips.showTipsInMainThread(Text: "支付信息同步成功")
            
            // 参赛状态更改
            YSBudge.setEnterCompetition("1")
            
            self!.tips.showTipsInMainThread(Text: "报名成功")
            
            fe_std_data_set_json("http_post_cache", key: "competitionInfo" + "detail" + self!.cpid + ysApplication.loginUser.uid, jsonValue: nil, expire_sec: DEFAULT_EXPIRE_SEC)
            
            self!.resetCompetitionProgress()
            
            if self!.competition_type == nil || self!.competition_type == "1" {
                // 线下赛事
                delayCall(1.0, block: { () -> Void in
                    self!.navigationController?.popViewControllerAnimated(true)
                })
                
                return
            }
            
            self!.gotoPublish()
        }
    }
    
    // 同步支付宝支付状态
    func updateAlipayStatus(oid: String, result_status: String, result: String) {
        
        tips.showActivityIndicatorViewInMainThread("正在同步支付信息")
        YSPay.updateAlipayStatus(oid, result_status: result_status, result: result, resp: { [weak self] (errorMsg: String!) -> Void in
            
            if self == nil {
                return
            }
            
            self!.isConfirm = false
            
            self!.tips.disappearActivityIndicatorViewInMainThread()
            
            if errorMsg != nil {
                self!.updateWrongTimes++
                
                if self!.updateWrongTimes > 2 {
                    
                    let alertController = UIAlertController(title: "提示", message: "请联系易赛客服,获取技术支持！\n支付号：\(oid)", preferredStyle: UIAlertControllerStyle.Alert)
                    let cancelAction = UIAlertAction(title: "确定", style: UIAlertActionStyle.Cancel, handler: nil)
                    alertController.addAction(cancelAction)
                    
                    if isUsingiPad() {
                        
                        alertController.popoverPresentationController?.sourceView = self!.view
                        alertController.popoverPresentationController?.sourceRect = self!.view.frame
                    }
                    
                    self!.presentViewController(alertController, animated: true, completion: nil)
                    return
                } else {
                    
                    let alertController = UIAlertController(title: "提示", message: "支付信息同步失败", preferredStyle: UIAlertControllerStyle.Alert)
                    let confirmAction = UIAlertAction(title: "再次同步", style: UIAlertActionStyle.Default, handler: { (action: UIAlertAction) -> Void in
                        self!.updateAlipayStatus(oid, result_status: result_status, result: result)
                    })
                    alertController.addAction(confirmAction)
                    
                    if isUsingiPad() {
                        
                        alertController.popoverPresentationController?.sourceView = self!.view
                        alertController.popoverPresentationController?.sourceRect = self!.view.frame
                    }
                    
                    self!.presentViewController(alertController, animated: true, completion: nil)
                }
                return
            }
            
            self!.tips.showTipsInMainThread(Text: "报名成功")
            
            // 参赛状态更改
            YSBudge.setEnterCompetition("1")
            
            self!.resetCompetitionProgress()
            
            fe_std_data_set_json("http_post_cache", key: "competitionInfo" + "detail" + self!.cpid + ysApplication.loginUser.uid, jsonValue: nil, expire_sec: DEFAULT_EXPIRE_SEC)
            
            if self!.competition_type == nil || self!.competition_type == "1" {
                // 线下赛事
                delayCall(1.0, block: { () -> Void in
                    self!.navigationController?.popViewControllerAnimated(true)
                })
                
                return
            }
            
            self!.gotoPublish()
        })
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
    
    // MARK: - Actions
    
    @IBAction func confirm(sender: AnyObject) {
        
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
        
        if checkInputEmpty(txf_name.text)  {
            tips.showTipsInMainThread(Text: "请填写姓名")
            return
        }
        
        if checkInputEmpty(txf_idNum.text)  {
            tips.showTipsInMainThread(Text: "请填写身份证信息")
            return
        }
        
        if checkInputEmpty(txf_tel.text)  {
            tips.showTipsInMainThread(Text: "请填写电话号码")
            return
        }
        
        if checkInputEmpty(txf_birth.text)  {
            tips.showTipsInMainThread(Text: "请填写生日信息")
            return
        }
        
        if cgid == nil && (confirmInfo.lst_competition_group != nil && confirmInfo.lst_competition_group.count > 0) {
            tips.showTipsInMainThread(Text: "请选择组别")
            return
        }
        
        if checkInputEmpty(txf_region.text) {
            tips.showTipsInMainThread(Text: "请填写联系地址")
            return
        }
        
        if isConfirm {
            tips.showTipsInMainThread(Text: "正在提交报名信息")
            return
        }
        
        isConfirm = true
        
        YSCompetition.confirmRegistration(cpid, cgid: cgid, realname: txf_name.text!, phone: txf_tel.text!, birth: txf_birth.text!, identity_card: txf_idNum.text!, region: txf_region.text!, institution: txf_institution.text,tch_name: "",tch_phone: "",version: "") { [weak self] (resp_crid: String!, errorMsg: String!) -> Void in
            
            if self == nil {
                return
            }
            
            self!.isConfirm = false
            
            if errorMsg != nil {
                
                self!.tips.showTipsInMainThread(Text: errorMsg)
                return
            }
            
            if !checkInputEmpty(self!.txf_name.text) {
                ysApplication.loginUser.setUserRealName(self!.txf_name.text!)
            }
            if !checkInputEmpty(self!.txf_birth.text) {
                ysApplication.loginUser.setUserBirth(self!.txf_birth.text!)
            }
            if !checkInputEmpty(self!.txf_tel.text) {
                ysApplication.loginUser.setUserTel(self!.txf_tel.text!)
            }
            if !checkInputEmpty(self!.txf_idNum.text) {
                ysApplication.loginUser.setUserIDCard(self!.txf_idNum.text!)
            }
            if !checkInputEmpty(self!.txf_region.text) {
                ysApplication.loginUser.setUserRegion(self!.txf_region.text!)
            }
            if !checkInputEmpty(self!.txf_institution.text) {
                ysApplication.loginUser.setUserInstitution(self!.txf_institution.text!)
            }
            
            if self!.confirmInfo.application_fee != nil && (self!.confirmInfo.application_fee as NSString).floatValue > 0.0 {
                
                // 赛事报名收费点击
                MobClick.event("join_competition", attributes: ["fee_type": "charge"])
                
            } else {
                
                // 赛事报名免费点击
                MobClick.event("join_competition", attributes: ["fee_type": "free"])
            }
            
            self!.crid = resp_crid
            
            if self!.confirmInfo.application_fee != nil && (self!.confirmInfo.application_fee as NSString).floatValue > 0.0 {
                
                self!.payController.showPayView()
            } else {
                
                // 参赛状态更改
                YSBudge.setEnterCompetition("1")
                
                self!.tips.showTipsInMainThread(Text: "报名成功")
                
                if self!.tabBarController != nil {
                    self!.tabBarController?.tabBar.showBadgeOnItemIndex(2)
                }
                
                fe_std_data_set_json("http_post_cache", key: "competitionInfo" + "detail" + self!.cpid + ysApplication.loginUser.uid, jsonValue: nil, expire_sec: DEFAULT_EXPIRE_SEC)
                
                self!.resetCompetitionProgress()
                
                if self!.competition_type == nil || self!.competition_type == "1" {
                    // 线下赛事
                    delayCall(1.0, block: { () -> Void in
                        self!.navigationController?.popViewControllerAnimated(true)
                    })
                    
                    return
                }
                
                self!.gotoPublish()
            }
        }
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return confirmInfo != nil ? 3 : 0
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        if section == 1 {
            return (confirmInfo == nil || confirmInfo.lst_competition_group.count < 1) ? 6 : 7
        }
        return 1
    }
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 1 {
            return 20.0
        }
        return 0.01
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        switch indexPath.section {
        case 0:
            return SCREEN_WIDTH * 53 / 102 + 97
        case 1:
            return 44.0
        default:
            return 60.0
        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        if indexPath.section == 1 && indexPath.row == 6 {
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
                        self!.lab_group.text = group.title
                        })
                    alertController.addAction(alertAction)
                }
                
                
                
                let cancelAction = UIAlertAction(title: "取消", style: UIAlertActionStyle.Cancel, handler: nil)
                alertController.addAction(cancelAction)
                
                if isUsingiPad() {
                    
                    alertController.popoverPresentationController?.sourceView = self.view
                    alertController.popoverPresentationController?.sourceRect = self.view.frame
                }
                
                presentViewController(alertController, animated: true, completion: nil)
            }
            
        } else if indexPath.section == 1 && indexPath.row == 1 {
            // 选择出生日期
            resignAllResponder()
            
            pickerController.showPicker()
        }
    }
    
    // MARK: - UITextFieldDelegate
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        
        resignAllResponder()
        
        return true
    }
    
    // MARK: - YSCustomPickerViewDelegate
    
    func changeDateString(dateString: String) {
        
        txf_birth.text = dateString
        
        self.tableView.reloadData()
    }
    
    // MARK: - YSCustomPayViewDelegate
    
    func gotoAliPay() {
        
        tips.showActivityIndicatorViewInMainThread("正在获取支付数据")
        
        // 支付宝支付
        YSPay.fetchAliPayOrderByCrid(crid, version: "",resp: { [weak self] (resp_order_info: String!, resp_oid: String!, errorMsg: String!) -> Void in
            
            if self == nil {
                return
            }
            
            if errorMsg != nil {
                
                self!.isConfirm = false
                self!.tips.showTipsInMainThread(Text: errorMsg)
                return
            }
            
            AlipaySDK.defaultService().payOrder(resp_order_info, fromScheme: "eysai", callback: { (resultDic: [NSObject : AnyObject]!) -> Void in
                
                if self == nil {
                    return
                }
                
                self!.isConfirm = false
                
                var resp_resultStatus: AnyObject! = resultDic["resultStatus"]
//                let resp_result: AnyObject! = resultDic["result"]
                /*
                9000 订单支付成功
                8000 正在处理中
                4000 订单支付失败
                6001 用户中途取消
                6002 网络连接出错
                */
                
                if resp_resultStatus is String {
                    resp_resultStatus = NSNumber(integer: Int((resp_resultStatus as! String))!)
                }
                //                            self!.updateAlipayStatus(resp_oid, result_status: "\(resp_resultStatus)", result: "\(resp_result)")
                switch resp_resultStatus.integerValue {
                case 9000:
                    
                    self!.tips.showTipsInMainThread(Text: "报名成功")
                    // 支付成功结果
                    MobClick.event("pay_result", attributes: ["result": "success", "platform": "alipay"])
                    
                    fe_std_data_set_json("http_post_cache", key: ysApplication.loginUser.uid + "competitionInfo" + "registrationConfirmationPage", jsonValue: nil,expire_sec: DEFAULT_EXPIRE_SEC)
                    
                    // 参赛状态更改
                    YSBudge.setEnterCompetition("1")
                    
                    fe_std_data_set_json("http_post_cache", key: "competitionInfo" + "detail" + self!.cpid + ysApplication.loginUser.uid, jsonValue: nil,expire_sec: DEFAULT_EXPIRE_SEC)
                    
                    self!.resetCompetitionProgress()
                    
                    if self!.competition_type == nil || self!.competition_type == "1" {
                        // 线下赛事
                        delayCall(1.0, block: { () -> Void in
                            self!.navigationController?.popViewControllerAnimated(true)
                        })
                        
                        return
                    }
                    
                    self!.gotoPublish()
                    
                case 8000:
                    self!.tips.showTipsInMainThread(Text: "正在处理中")
                case 4000:
                    self!.tips.showTipsInMainThread(Text: "订单支付失败")
                    
                    // 支付失败结果
                    MobClick.event("pay_result", attributes: ["result": "failure", "platform": "alipay"])
                    
                case 6001:
                    self!.tips.showTipsInMainThread(Text: "取消支付")
                case 6002:
                    self!.tips.showTipsInMainThread(Text: "网络连接出错")
                default:
                    break
                }
            })
        })
    }
    
    func gotoWXPay() {
        
        if !WXApi.isWXAppInstalled() {
            
            self.isConfirm = false
            
            tips.showTipsInMainThread(Text: "没有安装微信")
            return
        }
        
        if !WXApi.isWXAppSupportApi() {
            
            self.isConfirm = false
            
            tips.showTipsInMainThread(Text: "当前微信版本不支持支付功能")
            return
        }
        
        tips.showActivityIndicatorViewInMainThread("正在获取支付数据")
        
        // 微信支付
        YSPay.fetchWXPayOrderByCrid(crid,version: "",resp: { [weak self] (resp_order: YSWXPayOrder!, resp_oid: String!, errorMsg: String!) -> Void in
            
            if self == nil {
                return
            }
            
            self!.isConfirm = false
            
            if errorMsg != nil {
                
                self!.tips.showTipsInMainThread(Text: errorMsg)
                return
            }
            
            //                        println("before pay oid: \(resp_oid)")
            self!.wxpayoid = resp_oid
            
            let req = PayReq()
            req.openID = resp_oid
            req.partnerId = resp_order.partnerid
            req.prepayId = resp_order.prepayid
            req.nonceStr = resp_order.noncestr
            req.timeStamp = UInt32((resp_order.timestamp as NSString).intValue)
            req.package = resp_order.package
            req.sign = resp_order.sign
            
            WXApi.sendReq(req)
            
            self!.tips.disappearActivityIndicatorViewInMainThread()
        })
    }
    
    // MARK: - UIScrollViewDelegate
    
    override func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        
        pageControl.currentPage = Int(scrollView.contentOffset.x / SCREEN_WIDTH)
    }
    
    // MARK: - 支付回调
    
    // 微信支付回调
    
    func wechatPaySuccess(notification: NSNotification) {
        
//        if wxpayoid == nil {
//            return
//        }
//
//        let code = notification.object as? NSNumber
//        if code == nil {
//            return
//        }
        
//        updateWXPayStatus(wxpayoid, result: "\(code!)")
        
        self.isConfirm = false
        
        // 支付成功结果
        MobClick.event("pay_result", attributes: ["result": "success", "platform": "wxpay"])
        
        tips.showTipsInMainThread(Text: "报名成功")
        
        // 参赛状态更改
        YSBudge.setEnterCompetition("1")
        
        fe_std_data_set_json("http_post_cache", key: ysApplication.loginUser.uid + "competitionInfo" + "registrationConfirmationPage", jsonValue: nil,expire_sec: DEFAULT_EXPIRE_SEC)
        
        fe_std_data_set_json("http_post_cache", key: "competitionInfo" + "detail" + cpid + ysApplication.loginUser.uid, jsonValue: nil,expire_sec: DEFAULT_EXPIRE_SEC)
        
        resetCompetitionProgress()
        
        if competition_type == nil || competition_type == "1" {
            // 线下赛事
            delayCall(1.0, block: { () -> Void in
                self.navigationController?.popViewControllerAnimated(true)
            })
            
            return
        }
        
        gotoPublish()
    }
    
    func wechatPayFailed(notification: NSNotification) {
        
//        if wxpayoid == nil {
//            return
//        }
        
        tips.showTipsInMainThread(Text: "支付失败")
        
        isConfirm = false
        
        // 支付失败结果
        MobClick.event("pay_result", attributes: ["result": "failure", "platform": "wxpay"])
        
//        let code = notification.object as? NSNumber
//        if code == nil {
//            return
//        }
        
//        updateWXPayStatus(wxpayoid, result: "\(code)")
    }
    
    
}

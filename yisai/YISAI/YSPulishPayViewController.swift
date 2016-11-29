//
//  YSPulishPayViewController.swift
//  YISAI
//
//  Created by 周超创 on 16/8/19.
//  Copyright © 2016年 Shenzhen Jianbo Information Technology Co., Ltd. All rights reserved.
//

import UIKit

class YSPulishPayViewController: UIViewController,UITableViewDataSource,UITableViewDelegate,YSCustomPayViewDelegate {

    
    var isTch:Bool = true
    var payType:NSString = "Zhifubao"
    
    var payController: YSCustomPayViewController!
    
    
    var tips: FETips = FETips()
    var crid:String!
    
    var cpid: String! // 赛事ID
    
    var isConfirm:Bool!
    var wxpayoid: String!
    
    var match_name: String!
    var application_fee: String!
    var benefit_price: String!
    var real_price: String!
    
    
    var isRoot:Bool = true
    
    var competition_type: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.view.backgroundColor = UIColor.init(red: 235/255, green: 235/255, blue: 235/255, alpha: 1)
        
        self.title = "支付费用"
        
        tips.duration = 1
        
        var step:CGFloat = 6;
        if isTch == true
        {
            step = 7
        }
        
        
        let org_x:CGFloat = 0
        let org_y:CGFloat = 0
        let org_h:CGFloat = step*50+25
        
        
        let dataTable = UITableView(frame: CGRectMake(org_x, org_y, SCREEN_WIDTH, org_h),style:UITableViewStyle.Grouped)
        dataTable.dataSource = self
        dataTable.delegate  = self
        dataTable.scrollEnabled = false
        dataTable.backgroundColor = UIColor.init(red: 235/255, green: 235/255, blue: 235/255, alpha: 1)
        
        self.view.addSubview(dataTable);
        
        let hgt = (SCREEN_HEIGHT - org_h)/2+60

        let button =  UIButton(type:.Custom)
        button.frame=CGRectMake(15, SCREEN_HEIGHT-hgt, SCREEN_WIDTH-30, 43)
        button.setTitle("确定支付", forState:UIControlState.Normal) //普通状态下的文字
        button.setTitleColor(UIColor.whiteColor(),forState: .Normal) //普通状态下文字的颜色
        button.setTitleColor(UIColor.grayColor(),forState: .Highlighted) //普通状态下文字的颜色
        button.backgroundColor = UIColor.init(red: 239/255, green: 97/255, blue: 80/255, alpha: 1)
        button.layer.cornerRadius = 5
        button.addTarget(self,action:#selector(tapped),forControlEvents:.TouchUpInside)
        
        
        //  button.buttonType = UIButtonType.RoundedRect
        self.view.addSubview(button)
        
       // payController = UIStoryboard(name: "YSCustom", bundle: nil).instantiateViewControllerWithIdentifier("YSCustomPayViewController") as! YSCustomPayViewController
       // payController.delegate = self
       // self.view.addSubview(payController.view)
         if ysApplication.loginUser.role_type == "1"
         {
            isTch = false
        }
        else
         {
            isTch = true
        }
        
        
        if crid == nil {
            fetchCrid()
        }

    
        
        let leftBarBtn:UIBarButtonItem = UIBarButtonItem(image:UIImage(named: "cs_fanhui"), style: UIBarButtonItemStyle.Plain, target: self, action: #selector(backToPrevious))
        leftBarBtn.tintColor = UIColor.whiteColor()
        self.navigationItem.leftBarButtonItem = leftBarBtn
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    
    //获取报名ID
    func fetchCrid() {
        
        if cpid == nil {
            return
        }
        
        YSPublish.getCridByCpid(cpid, respBlock: { [weak self] (resp_crid: String!, errorMsg: String!) -> Void in
            
            if self == nil {
                return
            }
            
            if errorMsg != nil {
                self!.tips.showTipsInMainThread(Text: errorMsg)
                return
            }
            
            self!.crid = resp_crid
            // self!.localFindwork.crid = resp_crid
            })
    }
    
    
    
    //1.1默认返回一组
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if(isTch == true)
        {
            return 3;
        }
        else
        {
            return 2;
        }
    }
    
    // 1.2 返回行数
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(isTch == true)
        {
            if (section == 0)
            {
                return 2;
            }
            else if(section == 1 )
            {
                return 2;
            }
            else{
                return 3;
            }
        }
        else
        {
            
            return 3;
            
            
        }
    }
    
    //1.3 返回行高
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat{
        
        return 50;
        
    }
    
    //1.4每组的头部高度
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        if (section == 0)
        {
            return 10;
        }
        else if(section == 1 )
        {
            return 5;
        }
        else{
            return 10;
        }
    }
    
    //1.5每组的底部高度
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 1;
    }
    //1.6 返回数据源
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let identifier="identtifier";
        
        var cell=tableView.dequeueReusableCellWithIdentifier(identifier);
        if(cell == nil){
            cell=UITableViewCell(style: UITableViewCellStyle.Value1, reuseIdentifier: identifier);
        }
        //cell?.textLabel?.text = "测试"

        cell?.backgroundColor = UIColor.whiteColor()
        cell?.selectionStyle =  UITableViewCellSelectionStyle.None
        
        if(isTch == true)
        {
            if (indexPath.section == 0)
            {
                
               if indexPath.row == 0
                {
        
                    cell?.textLabel?.text = "赛事名称"
                    
                    cell?.detailTextLabel?.text = match_name
                    cell?.detailTextLabel?.textColor = UIColor.redColor();
                    cell?.detailTextLabel?.font = UIFont.systemFontOfSize(17)
                    cell?.detailTextLabel?.textAlignment = NSTextAlignment.Right
                }
                else
                {
                    cell?.textLabel?.text = "赛事费用"
                    
                   /* let txf_BounDate = UILabel(frame: CGRectMake(SCREEN_WIDTH-220,10,200,30))
                    txf_BounDate.textColor = UIColor.redColor()
                    txf_BounDate.textAlignment = NSTextAlignment.Right
                    txf_BounDate.text = "10人"
                    cell?.contentView.addSubview(txf_BounDate)*/
                    
                    
                    
                    if real_price == nil
                    {
                        cell?.detailTextLabel?.text = "¥0.0"
                    }
                    else
                    {
                        cell?.detailTextLabel?.text = "¥" + real_price
                    }
                    
                    cell?.detailTextLabel?.textColor = UIColor.redColor();
                    cell?.detailTextLabel?.font = UIFont.systemFontOfSize(17)
                    cell?.detailTextLabel?.textAlignment = NSTextAlignment.Right
                }

                
            }
            else if(indexPath.section == 1 )
            {
                if indexPath.row == 0
                {
                    
                    cell?.textLabel?.text = "优惠金额"
                    
                    if benefit_price == nil
                    {
                        cell?.detailTextLabel?.text = "¥0.0"
                    }
                    else
                    {
                        cell?.detailTextLabel?.text = "¥" + benefit_price
                    }

                    cell?.detailTextLabel?.textColor = UIColor.redColor();
                    cell?.detailTextLabel?.font = UIFont.systemFontOfSize(17)
                    cell?.detailTextLabel?.textAlignment = NSTextAlignment.Right
                }
                else
                {
                    cell?.textLabel?.text = "实付金额"
                    if application_fee == nil
                    {
                        cell?.detailTextLabel?.text = "¥0.0"
                    }
                    else
                    {
                        cell?.detailTextLabel?.text = "¥" + application_fee
                    }
                    
                    cell?.detailTextLabel?.textColor = UIColor.redColor();
                    cell?.detailTextLabel?.font = UIFont.systemFontOfSize(17)
                    cell?.detailTextLabel?.textAlignment = NSTextAlignment.Right
                }

                
            }
            else{
                
                switch indexPath.row {
                case 0:
                    cell?.textLabel?.text = "选择支付方式"
                    break;
                case 1:
                    // cell?.textLabel?.text = "支付宝"
                    
                    
                    cell?.accessoryType = UITableViewCellAccessoryType.None
                    let imageview = UIImageView(frame: CGRectMake(0, 0, 40, 40))
                    if(payType == "Zhifubao")
                    {
                        imageview.image = UIImage(named: "Isselect")
                    }
                    else
                    {
                        imageview.image = UIImage(named: "NotSelect")
                    }
                    cell?.accessoryView = imageview
                    
                    let left_img = UIImageView(frame: CGRectMake(15, 10, 30, 30))
                    left_img.image = UIImage(named: "pay_Zhifubao")
                    cell?.contentView.addSubview(left_img)
                    
                    let txf_BounDate = UILabel(frame: CGRectMake(50,10,200,30))
                    txf_BounDate.textColor = UIColor.blackColor()
                    txf_BounDate.textAlignment = NSTextAlignment.Left
                    txf_BounDate.text = "支付宝支付"
                    cell?.contentView.addSubview(txf_BounDate)
                    
                    break;
                default:
                    // cell?.textLabel?.text = "微信"
                    cell?.accessoryType = UITableViewCellAccessoryType.None
                    let imageview = UIImageView(frame: CGRectMake(0, 10, 40, 40))
                    if(payType == "Weixin")
                    {
                        imageview.image = UIImage(named: "Isselect")
                    }
                    else
                    {
                        imageview.image = UIImage(named: "NotSelect")
                    }
                    
                    cell?.accessoryView = imageview
                    let left_img = UIImageView(frame: CGRectMake(15, 10, 30, 30))
                    left_img.image = UIImage(named: "pay_Weixin")
                    cell?.contentView.addSubview(left_img)
                    
                    let txf_BounDate = UILabel(frame: CGRectMake(50,10,200,30))
                    txf_BounDate.textColor = UIColor.blackColor()
                    txf_BounDate.textAlignment = NSTextAlignment.Left
                    txf_BounDate.text = "微信支付"
                    cell?.contentView.addSubview(txf_BounDate)
                    
                    
                    
                    break;
                }

                
            }
        }
        else
        {
            
            if (indexPath.section == 0)
            {
                
                switch indexPath.row {
                case 0:
                    cell?.textLabel?.text = "赛事名称"
                   /* let txf_BounDate = UILabel(frame: CGRectMake(SCREEN_WIDTH-220,10,200,30))
                    txf_BounDate.textColor = UIColor.redColor()
                    txf_BounDate.textAlignment = NSTextAlignment.Right
                    txf_BounDate.text = "香港国际音乐节"
                    cell?.contentView.addSubview(txf_BounDate)*/
                    
                    cell?.detailTextLabel?.text = match_name
                    cell?.detailTextLabel?.textColor = UIColor.redColor();
                    cell?.detailTextLabel?.font = UIFont.systemFontOfSize(17)
                    cell?.detailTextLabel?.textAlignment = NSTextAlignment.Right
                    
                    break;
                case 1:
                    cell?.textLabel?.text = "参赛组别"
                    
                    /*let txf_BounDate = UILabel(frame: CGRectMake(SCREEN_WIDTH-220,10,200,30))
                    txf_BounDate.textColor = UIColor.redColor()
                    txf_BounDate.textAlignment = NSTextAlignment.Right
                    txf_BounDate.text = "少儿组"
                    cell?.contentView.addSubview(txf_BounDate)*/
                    
                    cell?.detailTextLabel?.text = "少儿组"
                    cell?.detailTextLabel?.textColor = UIColor.redColor();
                    cell?.detailTextLabel?.font = UIFont.systemFontOfSize(17)
                    cell?.detailTextLabel?.textAlignment = NSTextAlignment.Right
                    
                    break;
                default:
                    cell?.textLabel?.text = "报名费用"
                    
            
                    
                   /* let txf_BounDate = UILabel(frame: CGRectMake(SCREEN_WIDTH-220,10,200,30))
                    txf_BounDate.textColor = UIColor.redColor()
                    txf_BounDate.textAlignment = NSTextAlignment.Right
                    txf_BounDate.text = "¥130.00"
                    cell?.contentView.addSubview(txf_BounDate)*/
                    
                    cell?.detailTextLabel?.text = "¥" + application_fee
                    cell?.detailTextLabel?.textColor = UIColor.redColor();
                    cell?.detailTextLabel?.font = UIFont.systemFontOfSize(17)
                    cell?.detailTextLabel?.textAlignment = NSTextAlignment.Right
                }
                
            }
            else{
                switch indexPath.row {
                case 0:
                    cell?.textLabel?.text = "选择支付方式"
                    break;
                case 1:
                   // cell?.textLabel?.text = "支付宝"
                    
                    
                    cell?.accessoryType = UITableViewCellAccessoryType.None
                    let imageview = UIImageView(frame: CGRectMake(0, 0, 40, 40))
                    if(payType == "Zhifubao")
                    {
                        imageview.image = UIImage(named: "Isselect")
                    }
                    else
                    {
                        imageview.image = UIImage(named: "NotSelect")
                    }
                    cell?.accessoryView = imageview
             
                    let left_img = UIImageView(frame: CGRectMake(15, 10, 30, 30))
                    left_img.image = UIImage(named: "pay_Zhifubao")
                    cell?.contentView.addSubview(left_img)
                    
                    let txf_BounDate = UILabel(frame: CGRectMake(50,10,200,30))
                    txf_BounDate.textColor = UIColor.blackColor()
                    txf_BounDate.textAlignment = NSTextAlignment.Left
                    txf_BounDate.text = "支付宝支付"
                    cell?.contentView.addSubview(txf_BounDate)
                    
                    break;
                default:
                   // cell?.textLabel?.text = "微信"
                    cell?.accessoryType = UITableViewCellAccessoryType.None
                    let imageview = UIImageView(frame: CGRectMake(0, 10, 40, 40))
                    if(payType == "Weixin")
                    {
                        imageview.image = UIImage(named: "Isselect")
                    }
                    else
                    {
                        imageview.image = UIImage(named: "NotSelect")
                    }
                    
                    cell?.accessoryView = imageview
                    let left_img = UIImageView(frame: CGRectMake(15, 10, 30, 30))
                    left_img.image = UIImage(named: "pay_Weixin")
                    cell?.contentView.addSubview(left_img)
                    
                    let txf_BounDate = UILabel(frame: CGRectMake(50,10,200,30))
                    txf_BounDate.textColor = UIColor.blackColor()
                    txf_BounDate.textAlignment = NSTextAlignment.Left
                    txf_BounDate.text = "微信支付"
                    cell?.contentView.addSubview(txf_BounDate)
                    
                    
                    
                    break;
                }
            }
            
            
        }

        return cell!
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        if(isTch == true)
        {
            if (indexPath.section == 2)
            {
                if(indexPath.row == 1)
                {
                    payType = "Zhifubao"
                    tableView.reloadData()
                    
                }
                else if(indexPath.row == 2)
                {
                    
                    payType = "Weixin"
                    tableView.reloadData()
                }
                
                
            }
        }
        else
        {
            if (indexPath.section == 1)
            {
                if(indexPath.row == 1)
                {
                    payType = "Zhifubao"
                    tableView.reloadData()
                    
                }
                else if(indexPath.row == 2)
                {
                    
                    payType = "Weixin"
                    tableView.reloadData()
                }
                
                
            }
        }
            
        
    }
    
    func tapped()
    {
       //  self.payController.showPayView()
        if(payType == "Zhifubao")
        {
            gotoAliPay()
        }
        else
        {
            gotoWXPay()
        }
    }
    func gotoAliPay() {
        
        tips.showActivityIndicatorViewInMainThread("正在获取支付数据")
        
        var version:String = ""
        
        if(self.competition_type != nil &&  self.competition_type == "0")
        {
             version = NSBundle.mainBundle().infoDictionary!["CFBundleShortVersionString"] as! String
        }
        // 支付宝支付
        YSPay.fetchAliPayOrderByCrid(crid, version: version ,resp: { [weak self] (resp_order_info: String!, resp_oid: String!, errorMsg: String!) -> Void in
            
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
                    YSBudge.setEnterCompetition("4")
                    
                    
                    delayCall(1.5, block: {()->Void in
                        
                        self!.backToPrevious()
                        
                    })
                    
                    
                   /* fe_std_data_set_json("http_post_cache", key: "competitionInfo" + "detail" + self!.cpid + ysApplication.loginUser.uid, jsonValue: nil,expire_sec: DEFAULT_EXPIRE_SEC)
                    
                    self!.resetCompetitionProgress()
                   
                    if self!.competition_type == nil || self!.competition_type == "1" {
                        // 线下赛事
                        delayCall(1.0, block: { () -> Void in
                            self!.navigationController?.popViewControllerAnimated(true)
                        })
                        
                        return
                    }
                    
                    self!.gotoPublish()*/
                    
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
            
            isConfirm = false
            
            tips.showTipsInMainThread(Text: "没有安装微信")
            return
        }
        
        if !WXApi.isWXAppSupportApi() {
            
            isConfirm = false
            
            tips.showTipsInMainThread(Text: "当前微信版本不支持支付功能")
            return
        }
        
        tips.showActivityIndicatorViewInMainThread("正在获取支付数据")
        var version:String = ""
        
        if(self.competition_type != nil &&  self.competition_type == "0")
        {
            version = NSBundle.mainBundle().infoDictionary!["CFBundleShortVersionString"] as! String
        }
        
        // 微信支付
        YSPay.fetchWXPayOrderByCrid(crid,version: version, resp: { [weak self] (resp_order: YSWXPayOrder!, resp_oid: String!, errorMsg: String!) -> Void in
            
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
       YSBudge.setEnterCompetition("4")
        
        delayCall(1.5, block: {()->Void in
        
          self.backToPrevious()
            
        })
        
       /*  fe_std_data_set_json("http_post_cache", key: ysApplication.loginUser.uid + "competitionInfo" + "registrationConfirmationPage", jsonValue: nil,expire_sec: DEFAULT_EXPIRE_SEC)
        
       // fe_std_data_set_json("http_post_cache", key: "competitionInfo" + "detail" + cpid + ysApplication.loginUser.uid, jsonValue: nil,expire_sec: DEFAULT_EXPIRE_SEC)
        
        resetCompetitionProgress()
        
        if competition_type == nil || competition_type == "1" {
            // 线下赛事
            delayCall(1.0, block: { () -> Void in
                self.navigationController?.popViewControllerAnimated(true)
            })
            
            return
        }
        
        gotoPublish()*/
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
    //返回按钮点击响应
    func backToPrevious(){
        
      /*  let childViewControllers = navigationController!.childViewControllers
        
        
        for viewController in childViewControllers {
            
            if viewController is YSCompetitionDetailViewController {
                
                
                self.navigationController?.popToViewController(viewController, animated: true)
                
                return
            }
            
            
        }*/

        self.navigationController?.popToRootViewControllerAnimated(true)
   
        
    }
}

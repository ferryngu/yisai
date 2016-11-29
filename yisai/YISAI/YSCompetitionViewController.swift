//
//  YSCompetitionViewController.swift
//  YISAI
//
//  Created by Yufate on 15/5/29.
//  Copyright (c) 2015年 Shenzhen Jianbo Information Technology Co., Ltd. All rights reserved.
//

import UIKit

class YSCompetitionViewController: UIViewController {
    
    private struct AssociatedObject {
        static var GetCategoryIndex = "GetCategoryIndex"
        
        // 需求变动后添加
        static var GetTypeIndex = "GetCategoryIndex"
        // ----------
    }

    var competitionMainControllers: [YSCompetitionMainViewController]!
    var currentController: YSCompetitionMainViewController!
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var editItem: UIBarButtonItem!
    var retainEditItem: UIBarButtonItem!
    
    var tips: FETips = FETips()
    var currentIndex: Int = 0
    var type: Int!
    var guideView: UIImageView!
    
    var lst_category: [YSWorkCategory]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.automaticallyAdjustsScrollViewInsets = false

        // Do any additional setup after loading the view.
        tips.duration = 1
        
        retainEditItem = editItem
        self.navigationItem.rightBarButtonItem = nil
        
        configureScrollView()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if YSGuide.getUserGuideCompetition() == 0 {
            configureGuideView()
        }
        
        fetchCategory(true)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func fetchCategory(shouldCache: Bool) {
        
        YSPublish.getWorkCategory() { [weak self] (resp_lst_category: [YSWorkCategory]!, errorMsg: String!) -> Void in
            
            if self == nil {
                return
            }
            
            if errorMsg != nil {
                self!.tips.showTipsInMainThread(Text: errorMsg)
                return
            }
            
            if self!.lst_category == nil {
                self!.lst_category = resp_lst_category
                
                // 需求变动前
//                self!.configureCategoryView()
                // ----------
                // 需求变动后
                self!.configureTypeViewControllers()
                // -----------
            }
        }
    }
    
    func configureGuideView() {
        
        if guideView != nil {
            return
        }
        
        if ysApplication.loginUser.role_type != "1" {
            return
        }
        
        guideView = UIImageView(frame: CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: SCREEN_HEIGHT))
        if SCREEN_WIDTH == 320 {
            guideView.image = UIImage(named: "guide_competition_320")
        } else if SCREEN_WIDTH == 375 {
            guideView.image = UIImage(named: "guide_competition_375")
        } else if SCREEN_WIDTH == 414 {
            guideView.image = UIImage(named: "guide_competition_414")
        }
        guideView.contentMode = UIViewContentMode.TopLeft
        guideView.userInteractionEnabled = true
        guideView.backgroundColor = UIColor.clearColor()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: "tapGuideView:")
        guideView.addGestureRecognizer(tapGesture)
        
        ysApplication.tabbarController.view.addSubview(guideView)
    }
    
    // 需求变动前
    /*
    func configureCategoryView() {
        
        let btn_width = 60
        let btn_height = 40
        let originY = 0
        
        scrollView.contentSize = CGSize(width: btn_width * lst_category.count, height: btn_height)
        
        for subview in scrollView.subviews {
            subview.removeFromSuperview()
        }
        
        if competitionMainControllers != nil {
            for childViewController in self.childViewControllers {
                childViewController.removeFromParentViewController()
            }
            
            for subview in containerView.subviews {
                subview.removeFromSuperview()
            }
            competitionMainControllers.removeAll(keepCapacity: false)
        } else {
            competitionMainControllers = [YSCompetitionMainViewController]()
        }

        for (index, category) in enumerate(lst_category) {
            
            let originX = 60 * index
            let btn = UIButton(frame: CGRect(x: originX, y: originY, width: btn_width, height: btn_height))
            if index == 0 {
                btn.setAttributedTitle(NSAttributedString(string: category.category_name, attributes: [NSFontAttributeName : UIFont.systemFontOfSize(17, weight: 2), NSForegroundColorAttributeName : UIColor.redColor()]), forState: .Normal)
            } else {
                btn.setAttributedTitle(NSAttributedString(string: category.category_name, attributes: [NSFontAttributeName : UIFont.systemFontOfSize(15, weight: 2), NSForegroundColorAttributeName : UIColor.darkGrayColor()]), forState: .Normal)
            }
            btn.tag = 1000+index
            objc_setAssociatedObject(btn, &AssociatedObject.GetCategoryIndex, index, UInt(OBJC_ASSOCIATION_ASSIGN))
            btn.addTarget(self, action: "changeCategory:", forControlEvents: .TouchUpInside)
            scrollView.addSubview(btn)
            
            let controller = self.storyboard?.instantiateViewControllerWithIdentifier("YSCompetitionMainViewController") as! YSCompetitionMainViewController
            controller.view.frame = self.containerView.bounds
            controller.wcid = lst_category[index].wcid
            competitionMainControllers.append(controller)
            
            if index == 0 {
                addChildViewController(controller)
                containerView.addSubview(controller.view)
                currentController = controller
                currentIndex = 0
            }
        }
        
        self.navigationItem.rightBarButtonItem = retainEditItem
    }
    */
    // --------
    
    // 需求变动后添加方法
    func configureScrollView() {
        
        let btn_width = SCREEN_WIDTH / 4
        let btn_height = 40
        
        scrollView.contentSize = CGSize(width: Int(btn_width * 4), height: btn_height)
        
        let lst_types = ["全部赛事", "即将开始", "正在进行", "已经结束"]
        for index in 0...3 {
            
            let originX = Int(btn_width) * index
            let btn = UIButton(frame: CGRect(x: originX, y: 0, width: Int(btn_width), height: btn_height))
            if index == 0 {
                btn.setAttributedTitle(NSAttributedString(string: lst_types[index], attributes: [NSFontAttributeName : UIFont.systemFontOfSize(17), NSForegroundColorAttributeName : UIColor.redColor()]), forState: .Normal)
            } else {
                btn.setAttributedTitle(NSAttributedString(string: lst_types[index], attributes: [NSFontAttributeName : UIFont.systemFontOfSize(15), NSForegroundColorAttributeName : UIColor.darkGrayColor()]), forState: .Normal)
            }
            
            btn.tag = 1000 + index
            objc_setAssociatedObject(btn, &AssociatedObject.GetTypeIndex, index, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            btn.addTarget(self, action: "changeType:", forControlEvents: .TouchUpInside)
            scrollView.addSubview(btn)
        }
        
        self.navigationItem.rightBarButtonItem = nil
        
        // 用户配置(赛事筛选)
       // let conf = ysApplication.loginUser.conf
        //if conf == nil {
       //     return
       // }
        
       // let competition_search = conf["competition_search"] as? Int
        
       // if competition_search == nil {
         //   return
      //  }
        
      /*  if competition_search! == 0 {
            navigationItem.rightBarButtonItem = nil
        } else {
            navigationItem.rightBarButtonItem = retainEditItem
        }*/
    }
    
    func configureTypeViewControllers() {
        
        if competitionMainControllers != nil {
            for childViewController in self.childViewControllers {
                childViewController.removeFromParentViewController()
            }
            
            for subview in containerView.subviews {
                subview.removeFromSuperview()
            }
            competitionMainControllers.removeAll(keepCapacity: false)
        } else {
            competitionMainControllers = [YSCompetitionMainViewController]()
        }
        
        for index in 0...3 {
            
            let controller = self.storyboard?.instantiateViewControllerWithIdentifier("YSCompetitionMainViewController") as! YSCompetitionMainViewController
            controller.view.frame = self.containerView.bounds
            switch index {
            case 0:
                controller.type = nil
            case 1:
                controller.type = 3
            case 2:
                controller.type = 1
            case 3:
                controller.type = 2
            default:
                break
            }
            
            competitionMainControllers.append(controller)
            
            if index == 0 {
                addChildViewController(controller)
                containerView.addSubview(controller.view)
                currentController = controller
                currentIndex = 0
            }
        }
    }
    
    // 切换接口类型
    func switchType(fromWcid: String!, toWcid: String!, type: Int!) -> (String!, Int!)! {
        
        if currentController == nil {
            return nil
        }
        
        if fromWcid == nil {
            
            if toWcid == nil {
                // 原全赛事到全赛事，传type不变
                return (toWcid, type)
            } else {
                
                switch type {
                case nil:
                    // 原全赛事到分类全赛事
                    return (toWcid, nil)
                case 1:
                    // 原全赛事正在进行到分类正在进行
                    return (toWcid, 0)
                case 2:
                    // 原全赛事已经结束到分类已经结束
                    return (toWcid, 1)
                case 3:
                    // 原全赛事即将进行到分类即将进行
                    return (toWcid, 2)
                default:
                    return (toWcid, nil)
                }
            }
            
        } else {
            
            if toWcid == nil {
                
                switch type {
                case nil:
                    // 原分类全赛事到全赛事
                    return (toWcid, nil)
                case 1:
                    // 原分类正在进行到全赛事正在进行
                    return (toWcid, 2)
                case 2:
                    // 原分类已经结束到全赛事已经结束
                    return (toWcid, 3)
                case 0:
                    // 原分类即将进行到全赛事即将进行
                    return (toWcid, 1)
                default:
                    return (toWcid, nil)
                }
            } else {
                
                // 原分类赛事到分类赛事，传type不变
                return (toWcid, type)
            }
        }
    }
    
    // 切换条目
    func switchIndex() -> (String!, Int!)! {
        
        var swtType: (String!, Int!)! = nil
        
        if currentController == nil {
            return nil
        }
        
        if currentController.wcid == nil {
            
            switch currentIndex {
            case 0:
                swtType = switchType(currentController.wcid, toWcid: currentController.wcid, type: nil)
            case 1:
                swtType = switchType(currentController.wcid, toWcid: currentController.wcid, type: 3)
            case 2:
                swtType = switchType(currentController.wcid, toWcid: currentController.wcid, type: 1)
            case 3:
                swtType = switchType(currentController.wcid, toWcid: currentController.wcid, type: 2)
            default:
                break
            }
        } else {
            
            switch currentIndex {
            case 0:
                swtType = switchType(currentController.wcid, toWcid: currentController.wcid, type: nil)
            case 1:
                swtType = switchType(currentController.wcid, toWcid: currentController.wcid, type: 2)
            case 2:
                swtType = switchType(currentController.wcid, toWcid: currentController.wcid, type: 0)
            case 3:
                swtType = switchType(currentController.wcid, toWcid: currentController.wcid, type: 1)
            default:
                break
            }
        }
        
        return swtType
    }
    // -----------
    
    // 需求变动前
//    func reloadCategoryView() {
//        
//        for index in 0..<lst_category.count {
//            let btn = scrollView.viewWithTag(index+1000) as! UIButton
//            
//            if index == currentIndex {
//                btn.setAttributedTitle(NSAttributedString(string: btn.titleLabel!.text!, attributes: [NSFontAttributeName : UIFont.systemFontOfSize(17, weight: 2), NSForegroundColorAttributeName : UIColor.redColor()]), forState: .Normal)
//            } else {
//                btn.setAttributedTitle(NSAttributedString(string: btn.titleLabel!.text!, attributes: [NSFontAttributeName : UIFont.systemFontOfSize(15, weight: 2), NSForegroundColorAttributeName : UIColor.darkGrayColor()]), forState: .Normal)
//            }
//        }
//    }
    // ------------
    // 需求变动后
    func reloadScrollView() {
        
        for index in 0...3 {
            let btn = scrollView.viewWithTag(index+1000) as! UIButton
            
            if index == currentIndex {
                btn.setAttributedTitle(NSAttributedString(string: btn.titleLabel!.text!, attributes: [NSFontAttributeName : UIFont.systemFontOfSize(17), NSForegroundColorAttributeName : UIColor.redColor()]), forState: .Normal)
            } else {
                btn.setAttributedTitle(NSAttributedString(string: btn.titleLabel!.text!, attributes: [NSFontAttributeName : UIFont.systemFontOfSize(15), NSForegroundColorAttributeName : UIColor.darkGrayColor()]), forState: .Normal)
            }
        }
    }
    // -------------
    
    // MARK: - Actions
    
    func tapGuideView(tapGesture: UITapGestureRecognizer) {
        
        guideView.hidden = true
        guideView.removeFromSuperview()
        
        YSGuide.setUserGuideCompetition(1)
    }

    @IBAction func swipeToLeft(sender: AnyObject) {
        
        // 需求变动前
//        if currentIndex == lst_category.count - 1 {
//            return
//        }
        // ---------
        // 需求变动后
        if currentIndex == 3 {
            return
        }
        // ---------
        
        currentIndex++
        // 需求变动前
//        if 60 * (currentIndex+1) > Int(SCREEN_WIDTH) {
//            if scrollView.contentOffset.x + SCREEN_WIDTH <= scrollView.contentSize.width {
//                scrollView.contentOffset.x += 60
//            }
//        }
//        fromController(currentController, toController: competitionMainControllers[currentIndex], leftOrRight: 1)
//        reloadCategoryView()
        // ---------
        // 需求变动后
        
        let swtType = switchIndex()
        
        competitionMainControllers[currentIndex].wcid = swtType.0
        competitionMainControllers[currentIndex].type = swtType.1
        
        fromController(currentController, toController: competitionMainControllers[currentIndex], leftOrRight: 1)
        reloadScrollView()
        // ----------
    }
    
    @IBAction func swipeToRight(sender: AnyObject) {
        
        if currentIndex == 0 {
            return
        }
        
        currentIndex--
        // 需求变动前
//        if scrollView.contentOffset.x > 0 {
//            scrollView.contentOffset.x -= 60
//        }
//        fromController(currentController, toController: competitionMainControllers[currentIndex], leftOrRight: 2)
//        reloadCategoryView()
        // ---------
        // 需求变动后
        
        let swtType = switchIndex()
        
        competitionMainControllers[currentIndex].wcid = swtType.0
        competitionMainControllers[currentIndex].type = swtType.1
        
        fromController(currentController, toController: competitionMainControllers[currentIndex], leftOrRight: 2)
        reloadScrollView()
        // ---------
    }
    
    @IBAction func selectCompetition(sender: AnyObject) {
        
        // 需求变动前
//        let allCptionAction = UIAlertAction(title: "全部比赛", style: UIAlertActionStyle.Destructive) { [weak self] (action: UIAlertAction!) -> Void in
//            
//            if self == nil {
//                return
//            }
//            
//            self!.currentController.type = nil
//            self!.currentController.isLoadMore = false
//            self!.currentController.loadFindWorkIndex = 0
//            self!.currentController.fetchCompetitionInfo(true, type: nil)
//            self!.currentController.loadFindWorkIndex += 20
//        }
//        
//        let competitingAction = UIAlertAction(title: "正在进行的比赛", style: UIAlertActionStyle.Destructive) { [weak self] (action: UIAlertAction!) -> Void in
//            if self == nil {
//                return
//            }
//            
//            self!.currentController.type = 0
//            self!.currentController.isLoadMore = false
//            self!.currentController.loadFindWorkIndex = 0
//            self!.currentController.fetchCompetitionInfo(true, type: 0)
//            self!.currentController.loadFindWorkIndex += 20
//        }
//        
//        let competitedAction = UIAlertAction(title: "已经结束的比赛", style: UIAlertActionStyle.Destructive) { [weak self] (action: UIAlertAction!) -> Void in
//            
//            if self == nil {
//                return
//            }
//            
//            self!.currentController.type = 1
//            self!.currentController.isLoadMore = false
//            self!.currentController.loadFindWorkIndex = 0
//            self!.currentController.fetchCompetitionInfo(true, type: 1)
//            self!.currentController.loadFindWorkIndex += 20
//        }
//        let cancelAction = UIAlertAction(title: "取消", style: UIAlertActionStyle.Cancel, handler: nil)
//        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.ActionSheet)
//        alertController.addAction(allCptionAction)
//        alertController.addAction(competitingAction)
//        alertController.addAction(competitedAction)
//        alertController.addAction(cancelAction)
//        ysApplication.tabbarController.presentViewController(alertController, animated: true, completion: nil)
        // ----------
        
        // 需求变动后
        YSPublish.getWorkCategory() { [weak self] (resp_lst_category: [YSWorkCategory]!, errorMsg: String!) -> Void in
            
            if self == nil {
                return
            }
            
            if errorMsg != nil {
                self!.tips.showTipsInMainThread(Text: errorMsg)
                return
            }
            
            if self!.lst_category == nil {
                self!.lst_category = resp_lst_category
            }
            
            if ysApplication.tabbarController.presentedViewController != nil {
                return
            }
            
            let cancelAction = UIAlertAction(title: "取消", style: UIAlertActionStyle.Cancel, handler: nil)
            let alertController = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.ActionSheet)
            
            let allCategoryAction = UIAlertAction(title: "全部", style: UIAlertActionStyle.Destructive, handler: { (action: UIAlertAction) -> Void in
                
                if self == nil {
                    return
                }
                
//                self!.currentController.wcid = nil
                self!.currentController.isLoadMore = false
                self!.currentController.loadFindWorkIndex = 0
                
                let swtType = self!.switchType(self!.currentController.wcid, toWcid: nil, type: self!.currentController.type)
                self!.currentController.wcid = swtType.0
                self!.currentController.type = swtType.1
                
                self!.currentController.fetchCompetitionInfo(true, type: self!.currentController.type)
                self!.currentController.loadFindWorkIndex += 20
            })
            
            alertController.addAction(allCategoryAction)
            
            for category in resp_lst_category {
                
                let categoryAction = UIAlertAction(title: category.category_name, style: UIAlertActionStyle.Destructive, handler: { (action: UIAlertAction) -> Void in
                    
                    if self == nil {
                        return
                    }
                    
                    let swtType = self!.switchType(self!.currentController.wcid, toWcid: category.wcid, type: self!.currentController.type)
                    self!.currentController.wcid = swtType.0
                    self!.currentController.type = swtType.1
                    
                    self!.currentController.isLoadMore = false
                    self!.currentController.loadFindWorkIndex = 0
                    self!.currentController.fetchCompetitionInfo(true, type: self!.currentController.type)
                    self!.currentController.loadFindWorkIndex += 20
                })
                
                alertController.addAction(categoryAction)
            }
            
            alertController.addAction(cancelAction)
            
            if isUsingiPad() {
                
                let poc = UIPopoverController(contentViewController: alertController)
                poc.presentPopoverFromBarButtonItem(self!.navigationItem.rightBarButtonItem!, permittedArrowDirections: UIPopoverArrowDirection.Any, animated: true)
                
            } else {
                ysApplication.tabbarController.presentViewController(alertController, animated: true, completion: nil)
            }
        }
        // ---------
    }
    
    // 需求变动前
//    func changeCategory(button: UIButton) {
//        
//        for index in 0..<lst_category.count {
//            let btn = scrollView.viewWithTag(index+1000) as! UIButton
//            btn.setAttributedTitle(NSAttributedString(string: btn.titleLabel!.text!, attributes: [NSFontAttributeName : UIFont.systemFontOfSize(15, weight: 2), NSForegroundColorAttributeName : UIColor.darkGrayColor()]), forState: .Normal)
//        }
//        
//        button.setAttributedTitle(NSAttributedString(string: button.titleLabel!.text!, attributes: [NSFontAttributeName : UIFont.systemFontOfSize(17, weight: 2), NSForegroundColorAttributeName : UIColor.redColor()]), forState: .Normal)
//        
//        let categoryIndex = objc_getAssociatedObject(button, &AssociatedObject.GetCategoryIndex) as! Int
//        if currentIndex == categoryIndex {
//            return
//        }
//        
//        currentIndex = categoryIndex
//        fromController(currentController, toController: competitionMainControllers[currentIndex], leftOrRight: 0)
//    }
    // -------------
    // 需求变动后
    func changeType(button: UIButton) {
        
        let typeIndex = objc_getAssociatedObject(button, &AssociatedObject.GetTypeIndex) as! Int
        if currentIndex == typeIndex {
            return
        }
        
        for index in 0..<4 {
            let btn = scrollView.viewWithTag(index+1000) as! UIButton
            btn.setAttributedTitle(NSAttributedString(string: btn.titleLabel!.text!, attributes: [NSFontAttributeName : UIFont.systemFontOfSize(15), NSForegroundColorAttributeName : UIColor.darkGrayColor()]), forState: .Normal)
        }
        
        button.setAttributedTitle(NSAttributedString(string: button.titleLabel!.text!, attributes: [NSFontAttributeName : UIFont.systemFontOfSize(17), NSForegroundColorAttributeName : UIColor.redColor()]), forState: .Normal)
        
        currentIndex = typeIndex
        
        let swtType = switchIndex()
        
        competitionMainControllers[currentIndex].wcid = swtType.0
        competitionMainControllers[currentIndex].type = swtType.1
        
        
        fromController(currentController, toController: competitionMainControllers[currentIndex], leftOrRight: 0)
    }
    // -----------
    
    func fromController(oldController: UITableViewController, toController newController: UITableViewController, leftOrRight: Int) {
        
        addChildViewController(newController)
        var willAnimate: Bool = true
        var duration = 0.0
        switch leftOrRight {
        case 1:
            // 向左滑
            oldController.view.layer.transform = CATransform3DIdentity
            newController.view.layer.transform = CATransform3DMakeTranslation(SCREEN_WIDTH, 0, 0)
            duration = 0.3
        case 2:
            // 向右滑
            oldController.view.layer.transform = CATransform3DIdentity
            newController.view.layer.transform = CATransform3DMakeTranslation(-SCREEN_WIDTH, 0, 0)
            duration = 0.3
        default:
            // 非手势切换
            willAnimate = false
            duration = 0.0
            break
        }
        
        transitionFromViewController(oldController, toViewController: newController, duration: duration, options: UIViewAnimationOptions.CurveLinear, animations: { () -> Void in
            
            if willAnimate {
                if leftOrRight == 1 {
                    newController.view.layer.transform = CATransform3DIdentity
                    oldController.view.layer.transform = CATransform3DMakeTranslation(-SCREEN_WIDTH, 0, 0)
                } else {
                    newController.view.layer.transform = CATransform3DIdentity
                    oldController.view.layer.transform = CATransform3DMakeTranslation(SCREEN_WIDTH, 0, 0)
                }
            }
            
        }) { [weak self] (finished: Bool) -> Void in
            
            if finished {
                // 动画复位
                newController.view.layer.transform = CATransform3DIdentity
                oldController.view.layer.transform = CATransform3DIdentity
                
                newController.didMoveToParentViewController(self)
                oldController.willMoveToParentViewController(nil)
                oldController.removeFromParentViewController()
                self!.currentController = newController as! YSCompetitionMainViewController
                
            } else {
                self!.currentController = oldController as! YSCompetitionMainViewController
            }
        }
    }
}

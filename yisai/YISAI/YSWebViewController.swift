//
//  YSWebViewController.swift
//  YISAI
//
//  Created by Yufate on 15/8/24.
//  Copyright (c) 2015年 Shenzhen Jianbo Information Technology Co., Ltd. All rights reserved.
//

import UIKit

class YSWebViewController: UIViewController {
    
    @IBOutlet weak var webView: UIWebView!
    var requestUrl: NSURL!
    var title_str:String!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let request = NSURLRequest(URL: requestUrl)
        webView.loadRequest(request)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func webViewDidFinishLoad(webView: UIWebView) {
        if(title_str == nil)
        {
        self.navigationItem.title = webView.stringByEvaluatingJavaScriptFromString("document.title")
        }
        else
        {
            self.navigationItem.title = title_str;
        }
    }
}

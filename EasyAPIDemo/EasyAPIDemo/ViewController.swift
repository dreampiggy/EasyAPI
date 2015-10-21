//
//  ViewController.swift
//  EasyAPIDemo
//
//  Created by lizhuoli on 15/5/12.
//  Copyright (c) 2015年 dreampiggy. All rights reserved.
//

import UIKit

class ViewController: UIViewController, EasyAPIProtocol {

    @IBOutlet weak var webView: UIWebView!
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    var refresher: UIRefreshControl!
    override func viewDidLoad() {
        super.viewDidLoad()
        indicator.startAnimating()
        self.refresher = UIRefreshControl()
        self.refresher.attributedTitle = NSAttributedString(string: "Pull to refresh")
        self.refresher.addTarget(self, action: "refresh:", forControlEvents: UIControlEvents.ValueChanged)
        self.webView.scrollView.addSubview(refresher)
        sendAPI()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func sendAPI() {
        let easyAPI = EasyAPI(target: self)
        easyAPI.sendAPI("foo", path:"dreampiggy")
//        easyAPI.sendAPI("bar", body:"Nothing", param: "Test")
    }
    
    func getResult(tag: String, results: AnyObject) {
        indicator.stopAnimating()
        refresher.endRefreshing()
        let HTMLString = results as? String ?? "API Failed"
        webView.loadHTMLString(HTMLString, baseURL: NSURL(string: "http://www.dreampiggy.com"))
    }
    
    func getError(tag: String, error: NSError, statusCode: Int) {
        indicator.stopAnimating()
        UIAlertAction(title: "Error to send request", style: .Default, handler: nil)
        println("\(error)\n\(statusCode)")
    }
    
    func refresh(sender:AnyObject)
    {
        sendAPI()
    }
    
}


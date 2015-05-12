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
    override func viewDidLoad() {
        super.viewDidLoad()
        webView.loadRequest(NSURLRequest(URL: NSURL(string: "http://www.dreampiggy.com")!))
        
        let easyAPI = EasyAPI(target: self)
        easyAPI.sendAPI("foo")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func getResult(tag: String, results: AnyObject) {
        println(results)
    }
    
    func getError(tag: String, error: NSError, statusCode: Int) {
        println("\(error)\n\(statusCode)")
    }
    
}


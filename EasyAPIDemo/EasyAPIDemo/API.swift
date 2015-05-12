//
//  API.swift
//  Herald
//
//  Created by lizhuoli on 15/5/9.
//  Copyright (c) 2015年 WangShuo. All rights reserved.
//

import Foundation
import Alamofire

public protocol EasyAPIProtocol{
    func getResult(tag: String, results: AnyObject)
    func getError(tag: String, error: NSError, statusCode: Int)
}

public class EasyAPI{
    
    //manager是Alamofire的一个管理者，首先初始化一个
    var manager:AnyObject
    
    //apiList是从EasyAPI.plist属性表中获取的字典
    var apiList:NSDictionary?
    
    //代理模式的代理
    var delegate:EasyAPIProtocol
    
    required public init(target:EasyAPIProtocol){
        self.delegate = target
        manager = Alamofire.Manager.sharedInstance
        let bundle = NSBundle.mainBundle()
        let plistPath = bundle.pathForResource("EasyAPI", ofType: "plist") ?? ""
        if let plistContent = NSDictionary(contentsOfFile: plistPath){
            apiList = plistContent["API List"] as? NSDictionary
        }
    }
    
    func sendAPI(tag: String, param:String...) -> Bool{
        //发送API，要确保APIParameter数组按照API Info.plist表中规定的先后顺序
        if (apiList == nil){
            return false
        }
        if let apiName = apiList?[tag] as? NSDictionary{
            let apiURL = apiName["URL"] as? String ?? ""
            let apiMethod = apiName["Method"] as? String ?? "GET"
            let apiParamArray = apiName["Param"] as? [String] ?? []//从API列表中读到的参数列表
            var apiParameter = param//方法调用的传入参数列表
            
            if (apiParamArray.count == apiParameter.count){
                var apiParamDic:NSDictionary?
                if !(apiParamArray.isEmpty){
                    apiParamDic = NSDictionary(objects: apiParameter, forKeys: apiParamArray)//将从plist属性表中的读取到的参数数的值作为key，将方法传入的参数作为value，传入要发送的参数字典
                }
                self.postRequest(apiMethod, url: apiURL, parameter: apiParamDic, tag: tag)
                return true
            }
        }
        return false
    }
    
    //对请求结果进行代理
    func didReceiveResults(results: AnyObject, tag: String){
        if let resultsForDic = results as? NSDictionary{
            self.delegate.getResult(tag, results: resultsForDic)
        }
        else if let resultsForArray = results as? NSArray{
            self.delegate.getResult(tag, results: resultsForArray)
        }
        else if let resultsForString = results as? NSString{
            self.delegate.getResult(tag, results: resultsForString)
        }
        else{
            self.delegate.getError(tag, error: NSError(), statusCode:500)
        }
    }
    
    //对错误进行代理
    func didReceiveError(code: Int, error: NSError, tag: String) {
        self.delegate.getError(tag, error: error, statusCode:code)
    }
    
    //POST请求，接收MIME类型为text/html，只处理非JSON返回格式的数据
    func postRequest(method: String, url: String, parameter: NSDictionary?,tag: String)
    {
        let requestMethod:Alamofire.Method

        switch method{
        case "GET":
            requestMethod = Alamofire.Method.GET
        case "POST":
            requestMethod = Alamofire.Method.POST
        case "PUT":
            requestMethod = Alamofire.Method.PUT
        case "DELETE":
            requestMethod = Alamofire.Method.DELETE
        default:
            requestMethod = Alamofire.Method.GET
        }
        Alamofire.request(requestMethod, url, parameters: parameter as? [String : AnyObject] ?? nil)
            .response { (request, response, data, error) in
                if (error != nil){
                    self.didReceiveError(response?.statusCode ?? 500, error: error ?? NSError(), tag: tag)
                }
                if let receiveData = data as? NSData{
                    //按照NSDictionary -> NSArray -> NSString的顺序进行过滤
                    if let receiveDic = NSJSONSerialization.JSONObjectWithData(receiveData, options: NSJSONReadingOptions.MutableContainers, error: nil) as? NSDictionary{
                        println("\nResponse(Dictionary):\n\(receiveDic)\n***********\n")
                        self.didReceiveResults(receiveDic, tag: tag)
                    }
                    else if let receiveArray = NSJSONSerialization.JSONObjectWithData(receiveData, options: NSJSONReadingOptions.MutableContainers, error: nil) as? NSArray{
                        println("\nResponse(Array):\n\(receiveArray)\n***********\n")
                        self.didReceiveResults(receiveArray, tag: tag)
                    }
                    else if let receiveString = NSString(data: receiveData,encoding: NSUTF8StringEncoding){
                        println("\nResponse(String):\n\(receiveString)\n***********\n")
                        self.didReceiveResults(receiveString, tag: tag)
                    }//默认使用UTF-8编码
                    else{
                        self.didReceiveError(response?.statusCode ?? 500, error: error ?? NSError(), tag: tag)
                    }
                }
            
        }
    }
    
    //取消所有请求
    func cancelAllRequest(){
        manager.cancelAllOperations()
    }
}
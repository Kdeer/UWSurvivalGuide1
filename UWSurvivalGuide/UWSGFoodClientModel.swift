//
//  UWSGClientModel.swift
//  UWSurvivalGuide
//
//  Created by Xiaochao Luo on 2016-07-02.
//  Copyright © 2016 Xiaochao Luo. All rights reserved.
//

import Foundation
import UIKit


class UWSGFoodClientModel: NSObject {
    
    func taskForImage(imageURL: String, completionHandler: (imageData: NSData?, error: NSError?)->Void) -> NSURLSessionTask{
        let url = NSURL(string: imageURL)

        let request = NSURLRequest(URL: url!)
        let session = NSURLSession.sharedSession()
        
        let task = session.dataTaskWithRequest(request) {(data, response, error) in
            
//            print(data)
//            print(response)
            if error != nil {
               // print("Some error is here")
                completionHandler(imageData: nil, error: error)
            } else if data == nil{
              //  print("We didn't get the data")
                completionHandler(imageData: nil, error: nil)
            }else {
               // print("We get the data")
                completionHandler(imageData: data, error: nil)
            }
        }
        
        task.resume()
        return task
    }
    
    func taskForGetMethod(method: String, parameters: [String:AnyObject], completionHandlerForGet: (result:AnyObject!, error: NSError?)-> Void) -> NSURLSessionDataTask {
        
        var parameters = parameters
        
        parameters = [
        "key" : "d13ee19474e6baa9328907c41a2fd77a",
        "callback" : "0"
        ]
    
        let session = NSURLSession.sharedSession()
        let url = UWFoodURLFromParameters(parameters, withExtension: method)
        let request = NSMutableURLRequest(URL: url)
    
        let task = session.dataTaskWithRequest(request){(data, response, error) in
            guard error == nil else{
                completionHandlerForGet(result: nil, error: error)
            print("there is an error")
            return
            }
            
            guard let statusCode = (response as? NSHTTPURLResponse)?.statusCode where statusCode >= 200 && statusCode <= 299 else {
            print("your request returned a bad status code")
            return
            }
            
            guard let data = data else {
            print("here is no data")
            return
            }
            
            let parsedResults: AnyObject!
            do{
                parsedResults = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments)}catch{
                    print("cannot parse the data")
                    return
            }
            completionHandlerForGet(result: parsedResults, error: nil)
        }
    
        task.resume()
        return task
    }
    

    func UWFoodURLFromParameters(parameters: [String:AnyObject], withExtension: String? = nil) -> NSURL {
        
        let components = NSURLComponents()
        components.scheme = "https"
        components.host = "api.uwaterloo.ca"
        components.path = "/v2/" + (withExtension ?? "")
//        "/v2/foodservices/outlets.json"
        components.queryItems = [NSURLQueryItem]()
        
        for (key, value) in parameters {
            let queryItem = NSURLQueryItem(name: key, value: "\(value)")
            components.queryItems!.append(queryItem)
        }
        
        return components.URL!
    }
    
    func UWEventURLFromParameters(parameters: [String:AnyObject], withExtension: String? = nil) -> NSURL {
        
        let components = NSURLComponents()
        components.scheme = "https"
        components.host = "api.uwaterloo.ca"
        components.path = (withExtension ?? "")
        //        "/v2/foodservices/outlets.json"
        components.queryItems = [NSURLQueryItem]()
        
        for (key, value) in parameters {
            let queryItem = NSURLQueryItem(name: key, value: "\(value)")
            components.queryItems!.append(queryItem)
        }
        
        return components.URL!
    }
    
    class func sharedInstance() -> UWSGFoodClientModel {
        struct Singleton {
            static var sharedInstance = UWSGFoodClientModel()
        }
        return Singleton.sharedInstance
    }
    
    struct Caches {
        static let imageCache = ImageCache()
    }
    
    
    
    
}
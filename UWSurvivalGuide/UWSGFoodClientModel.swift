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
    
    func taskForImage(_ imageURL: String, completionHandler: @escaping (_ imageData: Data?, _ error: NSError?)->Void) -> URLSessionTask{
        let url = URL(string: imageURL)

        let request = URLRequest(url: url!)
        let session = URLSession.shared
        
        let task = session.dataTask(with: request, completionHandler: {(data, response, error) in
            
//            print(data)
//            print(response)
            if error != nil {
               // print("Some error is here")
                completionHandler(nil, error as NSError?)
            } else if data == nil{
              //  print("We didn't get the data")
                completionHandler(nil, nil)
            }else {
               // print("We get the data")
                completionHandler(data, nil)
            }
        }) 
        
        task.resume()
        return task
    }
    
   @discardableResult func taskForGetMethod(_ method: String, parameters: [String:AnyObject], completionHandlerForGet:  @escaping (_ result:AnyObject?, _ error: NSError?)-> Void) -> URLSessionDataTask {
        
        var parameters = parameters
        
        parameters = [
        "key" : "d13ee19474e6baa9328907c41a2fd77a" as AnyObject,
        "callback" : "0" as AnyObject
        ]
    
    print("We are doing your job")
        let session = URLSession.shared
        let url = UWFoodURLFromParameters(parameters, withExtension: method)
        let request = URLRequest(url: url)
    
        let task = session.dataTask(with: request, completionHandler: {(data, response, error) in
            guard error == nil else{
                completionHandlerForGet(nil, error as NSError?)
            print("there is an error")
            return
            }
            
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode , statusCode >= 200 && statusCode <= 299 else {
            print("your request returned a bad status code")
            return
            }
            
            guard let data = data else {
            print("here is no data")
            return
            }
            
            let parsedResults: AnyObject!
            do{
                parsedResults = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as AnyObject!
            }
            catch{
                    print("cannot parse the data")
                    return
            }
            completionHandlerForGet(parsedResults, nil)
        })
    
        task.resume()
        return task
    }
    

    func UWFoodURLFromParameters(_ parameters: [String:AnyObject], withExtension: String? = nil) -> URL {
        
        var components = URLComponents()
        components.scheme = "https"
        components.host = "api.uwaterloo.ca"
        components.path = "/v2/" + (withExtension ?? "")
//        "/v2/foodservices/outlets.json"
        components.queryItems = [URLQueryItem]()
        
        for (key, value) in parameters {
            let queryItem = URLQueryItem(name: key, value: "\(value)")
            components.queryItems!.append(queryItem)
        }
        
        return components.url!
    }
    
    func UWEventURLFromParameters(_ parameters: [String:AnyObject], withExtension: String? = nil) -> URL {
        
        var components = URLComponents()
        components.scheme = "https"
        components.host = "api.uwaterloo.ca"
        components.path = (withExtension ?? "")
        //        "/v2/foodservices/outlets.json"
        components.queryItems = [URLQueryItem]()
        
        for (key, value) in parameters {
            let queryItem = URLQueryItem(name: key, value: "\(value)")
            components.queryItems!.append(queryItem)
        }
        
        return components.url!
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

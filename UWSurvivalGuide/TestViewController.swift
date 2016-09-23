//
//  TestViewController.swift
//  UWSurvivalGuide
//
//  Created by Xiaochao Luo on 2016-09-23.
//  Copyright © 2016 Xiaochao Luo. All rights reserved.
//

import UIKit

class TestViewController: UIViewController {

    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        UWSGFoodClientModel.sharedInstance().taskForGetMethod("news/renison/2193.json", parameters: [:]){(result, error) in
            
            print(result)
        }
        
        
    }
    
    @IBAction func GoGoButton(_ sender: AnyObject) {
        
        let controller = self.storyboard!.instantiateViewController(withIdentifier: "TestViewController1") as! TestViewController1
        
        self.navigationController!.pushViewController(controller, animated: true)
        
    }
    
    
    
    func taskForGetMethod(_ method: String, parameters: [String:AnyObject], completionHandlerForGet:  @escaping (_ result:AnyObject?, _ error: NSError?)-> Void) -> URLSessionTask {
        
        var parameters = parameters
        
        parameters = [
            "key" : "d13ee19474e6baa9328907c41a2fd77a" as AnyObject,
            "callback" : "0" as AnyObject
        ]
        
        print("We are doing your job")
        let session = URLSession.shared
        let url = UWSGFoodClientModel.sharedInstance().UWFoodURLFromParameters(parameters, withExtension: method)
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



}

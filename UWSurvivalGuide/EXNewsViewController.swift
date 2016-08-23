//
//  EXNewsViewController.swift
//  UWSurvivalGuide
//
//  Created by Xiaochao Luo on 2016-07-25.
//  Copyright © 2016 Xiaochao Luo. All rights reserved.
//

import Foundation
import UIKit



extension NewsViewController {
    
    func getNewsData(){
        freshingIndicator.hidden = false
        freshingIndicator.startAnimating()
        tableView.hidden = true
        UWSGFoodClientModel.sharedInstance().taskForGetMethod("news.json", parameters: [:]){ (result,error) in
            
            print("(\(self.TheNumberI) in getNewsData)")
            if error == nil {
                performUIUpdatesOnMain(){
                    if let data = result["data"] as? [[String:AnyObject]] {
                        self.TheDataNumber = data.count
                        NSUserDefaults.standardUserDefaults().setInteger(self.TheDataNumber, forKey: "TheDataNumber")
                        
                        
                        if self.TheNumberI-1 == data.count {
                            print("This is the last page")
                            self.condition = 1
                            NSUserDefaults.standardUserDefaults().setInteger(self.condition, forKey: "condition")
                        }else if self.TheNumberI == data.count {
                            let newsInfo = data[data.count-2...data.count-1].map(){(dictionary: [String:AnyObject]) -> News in
                                let newsInfo = News(dictionary: dictionary, context: sharedContext)
                                return newsInfo
                            }
                            self.condition = 1
                            self.newsList = newsInfo
                            NSUserDefaults.standardUserDefaults().setInteger(self.condition, forKey: "condition")
                        } else if self.TheNumberI+4 >= data.count {
                            let newsInfo = data[self.TheNumberI...data.count-1].map(){(dictionary: [String:AnyObject]) -> News in
                                let newsInfo = News(dictionary: dictionary, context: sharedContext)
                                return newsInfo
                            }
                            self.condition = 1
                            self.newsList = newsInfo
                            NSUserDefaults.standardUserDefaults().setInteger(self.condition, forKey: "condition")
                        }else {
                            self.condition = 2
                            let newsInfo = data[self.TheNumberI...self.TheNumberI+4].map(){(dictionary: [String:AnyObject]) -> News in
                                let newsInfo = News(dictionary: dictionary, context: sharedContext)
                                return newsInfo
                            }
                            self.newsList = newsInfo
                            NSUserDefaults.standardUserDefaults().setInteger(self.condition, forKey: "condition")
                        }
                        
                    }
                    
                    self.getNewsDetailData()
                    saveContext()
                    self.textField.placeholder = "\(self.TheNumberI/5+1)/\(self.TheDataNumber/5+1)"
                }
            }else {
                let alertController = UIAlertController(title: "Oops!", message: "There is a Network Error", preferredStyle: .Alert)
                let OkayAction = UIAlertAction(title: "Okay", style: .Default, handler: nil)
                alertController.addAction(OkayAction)
                self.presentViewController(alertController, animated: true, completion: nil)
                self.freshingIndicator.stopAnimating()
                self.freshingIndicator.hidden = true
            }
        }
    }


    func getNewsDetailData(){
    
        
        for i in 0...newsList.count - 1 {
            UWSGFoodClientModel.sharedInstance().taskForGetMethod("news/\(newsList[i].site)/\(newsList[i].id).json", parameters: [:]){(result, error) in
    
    
                if error == nil {
                    
                    performUIUpdatesOnMain(){
                    if let data = result["data"] as? [String:AnyObject] {
                        let image = data["image"] as? [String:AnyObject]
                        let imageURL = image!["url"] as? String
                        let descriptions = data["description"] as? String
                        let descriptions_raw = data["description_raw"] as? String
                        if descriptions != nil {
                        self.newsList[i].descriptions = descriptions_raw
                        }
                        
                        if descriptions_raw != nil {
                            self.newsList[i].descriptions_raw = descriptions_raw
                        }
                        
                        if imageURL != nil {
                            self.newsList[i].imageURL = imageURL
                        }
                        
                        }
                        self.tableView.reloadData()

                        self.nextButton.enabled = true
                        self.previousButton.enabled = true
                        
                        self.freshingIndicator.hidden = true
                        self.freshingIndicator.stopAnimating()
                        self.tableView.hidden = false
                    }

                }else {
                    let alertController = UIAlertController(title: "Oops!", message: "There is a Network Error", preferredStyle: .Alert)
                    let OkayAction = UIAlertAction(title: "Okay", style: .Default, handler: nil)
                    alertController.addAction(OkayAction)
                    self.presentViewController(alertController, animated: true, completion: nil)
                    self.freshingIndicator.stopAnimating()
                    self.freshingIndicator.hidden = true
                }
            }
        }
    }
    
    func timeCheck(theTime: String) -> String{
        
        var theTime = theTime
        let editedTime = theTime.componentsSeparatedByString("-")
        theTime = editedTime[0]+"-"+editedTime[1]+"-"+editedTime[2]+"-00:00"

        let dateFormatter = NSDateFormatter()
        dateFormatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZ"
        dateFormatter.dateFromString(theTime)
        let theDate = dateFormatter.dateFromString(theTime)
        
        var theDateString = String(theDate!).componentsSeparatedByString(" ")
        
        let weekDays = ["Sunday","Monday","Tuesday","Wednesday","Tuesday","Friday","Saturday"]
        
        let formatter  = NSDateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let todayDate = formatter.dateFromString(theDateString[0])!
        let myCalendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)!
        let myComponents = myCalendar.components(.Weekday, fromDate: todayDate)
        let weekDay = myComponents.weekday
        
        var theFinalDate = String()
        
        if theDateString[1] == "00:00:00" {
            theFinalDate = theDateString[0] + " \(weekDays[weekDay-1])"
        }else {
             theFinalDate = theDateString[0] + " \(weekDays[weekDay-1])" + " \(theDateString[1])"
        }
        
        return theFinalDate
    }
    
    func pathForIdentifier(identifier: String) -> String {
        let documentsDirectoryURL: NSURL = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first!
        let fullURL = documentsDirectoryURL.URLByAppendingPathComponent(identifier)
        
        return fullURL.path!
    }
    
    func deleteThings() {
        for i in 0...newsList.count - 1 {
            do {
                try NSFileManager.defaultManager().removeItemAtPath(pathForIdentifier(String(newsList[i].id)))
            }catch _ {}
            sharedContext.deleteObject(self.newsList[i])
        }
        self.newsList.removeAll()
        saveContext()
    }

}

extension NewsViewController: UITextFieldDelegate {
    
    func subscribeToKeyboardNotifications(){
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(NewsViewController.keyboardWillShow(_:)), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(NewsViewController.keyboardWillHide(_:)), name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func unsubscribeFromKeyboardNotifications(){
        NSNotificationCenter.defaultCenter().removeObserver(self,name:UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name:UIKeyboardWillHideNotification, object:nil)
    }
    
    func keyboardWillShow(notification: NSNotification){
        view.frame.origin.y = -(getKeyboardHeight(notification))
    }
    
    func keyboardWillHide(notification: NSNotification){
        view.frame.origin.y = 0
    }
    
    func getKeyboardHeight(notification: NSNotification) -> CGFloat{
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey]
            as! NSValue
        return keyboardSize.CGRectValue().height
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {

        textField.resignFirstResponder()
        return true
    }
    
    
    
    
    
    
}


extension String {
    
    subscript (i: Int) -> Character {
        return self[self.startIndex.advancedBy(i)]
    }
    
    subscript (i: Int) -> String {
        return String(self[i] as Character)
    }
    
    subscript (r: Range<Int>) -> String {
        let start = startIndex.advancedBy(r.startIndex)
        let end = start.advancedBy(r.endIndex - r.startIndex)
        return self[Range(start ..< end)]
    }
}
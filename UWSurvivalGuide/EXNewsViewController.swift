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
        freshingIndicator.isHidden = false
        freshingIndicator.startAnimating()
        tableView.isHidden = true
        UWSGFoodClientModel.sharedInstance().taskForGetMethod("news.json", parameters: [:]){ (result,error) in
            

            print("(\(self.TheNumberI) in getNewsData)")
            if error == nil {
                performUIUpdatesOnMain(){
                    if let data = result?["data"] as? [[String:AnyObject]] {
                        self.TheDataNumber = data.count
                        UserDefaults.standard.set(self.TheDataNumber, forKey: "TheDataNumber")
                        
                        
                        if self.TheNumberI-1 == data.count {
                            print("This is the last page")
                            self.condition = 1
                            UserDefaults.standard.set(self.condition, forKey: "condition")
                        }else if self.TheNumberI == data.count {
                            let newsInfo = data[data.count-2...data.count-1].map(){(dictionary: [String:AnyObject]) -> News in
                                let newsInfo = News(dictionary: dictionary, context: sharedContext)
                                return newsInfo
                            }
                            self.condition = 1
                            self.newsList = newsInfo
                            UserDefaults.standard.set(self.condition, forKey: "condition")
                        } else if self.TheNumberI+4 >= data.count {
                            let newsInfo = data[self.TheNumberI...data.count-1].map(){(dictionary: [String:AnyObject]) -> News in
                                let newsInfo = News(dictionary: dictionary, context: sharedContext)
                                return newsInfo
                            }
                            self.condition = 1
                            self.newsList = newsInfo
                            UserDefaults.standard.set(self.condition, forKey: "condition")
                        }else {
                            self.condition = 2
                            let newsInfo = data[self.TheNumberI...self.TheNumberI+4].map(){(dictionary: [String:AnyObject]) -> News in
                                let newsInfo = News(dictionary: dictionary, context: sharedContext)
                                return newsInfo
                            }
                            self.newsList = newsInfo
                            UserDefaults.standard.set(self.condition, forKey: "condition")
                        }

                    }
                    
                    self.getNewsDetailData()
                    saveContext()
                    self.textField.placeholder = "\(self.TheNumberI/5+1)/\(self.TheDataNumber/5+1)"
                }
            }else {
                let alertController = UIAlertController(title: "Oops!", message: "There is a Network Error", preferredStyle: .alert)
                let OkayAction = UIAlertAction(title: "Okay", style: .default, handler: nil)
                alertController.addAction(OkayAction)
                self.present(alertController, animated: true, completion: nil)
                self.freshingIndicator.stopAnimating()
                self.freshingIndicator.isHidden = true
            }
        }
    }


    func getNewsDetailData(){
        
        for i in 0...newsList.count - 1 {
            
            print(newsList[i].id, newsList[i].site)
            UWSGFoodClientModel.sharedInstance().taskForGetMethod("news/\(newsList[i].site!)/\(newsList[i].id!).json", parameters: [:]){(result, error) in

//                print(result)
    
                if error == nil {
                    
                    performUIUpdatesOnMain(){
                    if let data = result?["data"] as? [String:AnyObject] {
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

                        self.nextButton.isEnabled = true
                        self.previousButton.isEnabled = true
                        
                        self.freshingIndicator.isHidden = true
                        self.freshingIndicator.stopAnimating()
                        self.tableView.isHidden = false
                    }

                }else {
                    let alertController = UIAlertController(title: "Oops!", message: "There is a Network Error", preferredStyle: .alert)
                    let OkayAction = UIAlertAction(title: "Okay", style: .default, handler: nil)
                    alertController.addAction(OkayAction)
                    self.present(alertController, animated: true, completion: nil)
                    self.freshingIndicator.stopAnimating()
                    self.freshingIndicator.isHidden = true
                }
            }
        }
    }
    
    @discardableResult func timeCheck(_ theTime: String) -> String{
        
        var theTime = theTime
        let editedTime = theTime.components(separatedBy: "-")
        theTime = editedTime[0]+"-"+editedTime[1]+"-"+editedTime[2]+"-00:00"

        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZ"
        dateFormatter.date(from: theTime)
        let theDate = dateFormatter.date(from: theTime)
        
        var theDateString = String(describing: theDate!).components(separatedBy: " ")
        
        let weekDays = ["Sunday","Monday","Tuesday","Wednesday","Tuesday","Friday","Saturday"]
        
        let formatter  = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let todayDate = formatter.date(from: theDateString[0])!
        let myCalendar = Calendar(identifier: Calendar.Identifier.gregorian)
        let myComponents = (myCalendar as NSCalendar).components(.weekday, from: todayDate)
        let weekDay = myComponents.weekday
        
        var theFinalDate = String()
        
        if theDateString[1] == "00:00:00" {
            theFinalDate = theDateString[0] + " \(weekDays[weekDay!-1])"
        }else {
             theFinalDate = theDateString[0] + " \(weekDays[weekDay!-1])" + " \(theDateString[1])"
        }
        
        return theFinalDate
    }
    
    func pathForIdentifier(_ identifier: String) -> String {
        let documentsDirectoryURL: URL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let fullURL = documentsDirectoryURL.appendingPathComponent(identifier)
        
        return fullURL.path
    }
    
    func deleteThings() {
        for i in 0...newsList.count - 1 {
            do {
                try FileManager.default.removeItem(atPath: pathForIdentifier(String(describing: newsList[i].id)))
            }catch _ {}
            sharedContext.delete(self.newsList[i])
        }
        self.newsList.removeAll()
        saveContext()
    }

}

extension NewsViewController: UITextFieldDelegate {
    
    func subscribeToKeyboardNotifications(){
        NotificationCenter.default.addObserver(self, selector: #selector(NewsViewController.keyboardWillShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(NewsViewController.keyboardWillHide(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    func unsubscribeFromKeyboardNotifications(){
        NotificationCenter.default.removeObserver(self,name:NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name:NSNotification.Name.UIKeyboardWillHide, object:nil)
    }
    
    func keyboardWillShow(_ notification: Notification){
        view.frame.origin.y = -(getKeyboardHeight(notification))
    }
    
    func keyboardWillHide(_ notification: Notification){
        view.frame.origin.y = 0
    }
    
    func getKeyboardHeight(_ notification: Notification) -> CGFloat{
        let userInfo = (notification as NSNotification).userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey]
            as! NSValue
        return keyboardSize.cgRectValue.height
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {

        textField.resignFirstResponder()
        return true
    }
    
    
    
    
    
    
}


extension String {
    
    subscript (i: Int) -> Character {
        return self[self.characters.index(self.startIndex, offsetBy: i)]
    }
    
    subscript (i: Int) -> String {
        return String(self[i] as Character)
    }
    
    func substring(_ r: Range<Int>) -> String {
        let fromIndex = self.index(self.startIndex, offsetBy: r.lowerBound)
        let toIndex = self.index(self.startIndex, offsetBy: r.upperBound - 1)
        return self.substring(with: Range<String.Index>(uncheckedBounds: (lower: fromIndex, upper: toIndex)))
    }
    
//    subscript (r: Range<Int>) -> String {
//        get {
//            
//            let startIndex1 = self.index
//            
////            let startIndex = self.startIndex.advancedBy(r.lowerBound)
//            let startIndex2 = self.index(before: <#T##String.Index#>)
//            let endIndex = startIndex.advancedBy(r.upperBound - r.lowerBound)
//            
//            return self[Range(start: startIndex, end: endIndex)]
//        }
//    }

}

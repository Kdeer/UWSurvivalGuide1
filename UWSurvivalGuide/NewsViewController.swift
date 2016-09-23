//
//  NewsViewController.swift
//  UWSurvivalGuide
//
//  Created by Xiaochao Luo on 2016-07-24.
//  Copyright © 2016 Xiaochao Luo. All rights reserved.
//

import UIKit
import Foundation
import CoreData
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}



class NewsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var previousButton: UIButton!
    @IBOutlet weak var freshingIndicator: UIActivityIndicatorView!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var goButton: UIButton!
    
    
    var newsList = [News]()
    var TheNumberI: Int! = 0
    var TheDataNumber = Int()
    var condition = 2
    var descriptionString = String()
    var imageURL = String()
    
    var refresh: Bool {
        return (UIApplication.shared.delegate as! AppDelegate).refresh
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.automaticallyAdjustsScrollViewInsets = false
        tableView.delegate = self
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 400
        textField.delegate = self 
        (UIApplication.shared.delegate as! AppDelegate).myViewController = self
        
        fetchAndLoad()

    }
    
    override func viewWillAppear(_ animated: Bool) {

//        print(newsList[0].descriptions)
        subscribeToKeyboardNotifications()

        print("the newListNumber is \(self.newsList.count)")
        print("theNumberI's number is \(self.TheNumberI)")
        print("TheDataNumber number is \(self.TheDataNumber)")
        print("The condition Number is \(self.condition)")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        unsubscribeFromKeyboardNotifications()
    }
    

    
    func fetchAndLoad() {
        freshingIndicator.isHidden = true
        if refresh == true {
            
            tableView.isHidden = true
            freshingIndicator.isHidden = false
            freshingIndicator.startAnimating()
            print("refreshing time")
            if self.newsList.count > 0 {
            deleteThings()
            }
            self.TheNumberI = 0
            self.condition = 2
            print(self.newsList.count)
            getNewsData()
            
        }else {
            self.TheNumberI = UserDefaults.standard.integer(forKey: "TheNumberI")
            self.condition = UserDefaults.standard.integer(forKey: "condition")
            self.TheDataNumber = UserDefaults.standard.integer(forKey: "TheDataNumber")
            self.textField.placeholder = "\(self.TheNumberI/5+1)/\(self.TheDataNumber/5+1)"
            newsList = fetchAllNews()
            if newsList.isEmpty == false {
                print("fetching")
                getNewsDetailData()
                tableView.reloadData()
            }else {
                print("The fetched file is nil, reloading")
                getNewsData()
            }
        }


    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.newsList.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! NewsTableViewCell
        cell.indicator.isHidden = true
        if newsList.count > 0 {
        let newsRow = newsList[(indexPath as NSIndexPath).row]
        cell.titleLabel.text = newsRow.title

        if newsRow.descriptions_raw != nil{
            if let doc = HTML(html: newsRow.descriptions_raw!, encoding: String.Encoding(rawValue: String.Encoding.utf8.rawValue)){
            let length = doc.content!.characters.count
            if length > 100 {
//        let newsString = String(doc.content!)
                let index1 = doc.content!.index(doc.content!.startIndex, offsetBy: 90)
                cell.descriptionLabel.text = (doc.content?.substring(to: index1))! + " ..."
//        cell.descriptionLabel.text = doc.content!.substring(1..<90) + " ..."
            }else {
//                let newsString = String(doc.content!)
            cell.descriptionLabel.text = doc.content!.substring(0..<(length-10))

                }
            }
        }else {
            
            cell.descriptionLabel.text = newsRow.descriptions
            }
        
        
        
        var posterImage = UIImage(named: "campus bubble")
        cell.newsImageView.contentMode = .scaleAspectFit
            
            if newsRow.imageURL == nil || newsRow.imageURL == "" {
                posterImage = UIImage(named: "Campus Bubble")!
            }else if newsRow.newsImage != nil {
                posterImage = newsRow.newsImage!
            }else {
                cell.indicator.isHidden = false
                cell.indicator.startAnimating()
                let task = UWSGFoodClientModel.sharedInstance().taskForImage(newsRow.imageURL) {(imageData, error) in
                    
                    if let data = imageData {
                        performUIUpdatesOnMain(){
                            newsRow.newsImage = UIImage(data: data)
                            tableView.reloadData()
                            cell.indicator.stopAnimating()
                            cell.indicator.isHidden = true
                        }
                    }
                }
                
                    cell.taskToCancelifCellIsReused = task

        }

        
            cell.newsImageView.image = posterImage
    }

        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
//        let cell = tableView.cellForRowAtIndexPath(indexPath) as! NewsTableViewCell
        
        let newsRow = newsList[(indexPath as NSIndexPath).row]

//        if newsRow.descriptions != nil {
//                self.descriptionString = newsRow.descriptions!
//            }else
            if newsRow.descriptions_raw != nil {
                        
            if let doc = HTML(html: newsRow.descriptions_raw!, encoding: String.Encoding(rawValue: String.Encoding.utf8.rawValue)){
                self.descriptionString = doc.content!
            }
                }else {
                    let app = UIApplication.shared
                    if newsRow.link != nil {
                        app.openURL(URL(string: newsRow.link!)!)
            }
        }
        let time = "Published at " + self.timeCheck(newsRow.published) + ", Updated at \(self.timeCheck(newsRow.updatedAt))"
        if newsRow.imageURL != nil {
            let controller = self.storyboard!.instantiateViewController(withIdentifier: "NewsDetailViewController") as! NewsDetailViewController
            controller.titleLabelText = newsRow.title
            controller.timeLabelText = time
            controller.descriptionString = self.descriptionString

            controller.imageURL = newsRow.imageURL
            controller.newsList = newsRow
            
            
            self.navigationController!.pushViewController(controller, animated: true)
        }else {
            let controller = self.storyboard!.instantiateViewController(withIdentifier: "NewsDetailViewController1") as! NewsDetailViewController1
            controller.titleLabelText = newsRow.title
            controller.timeLabelText = time
            controller.descriptionString = self.descriptionString
            
            
            self.navigationController!.pushViewController(controller, animated: true)
        }
        
        timeCheck(newsRow.updatedAt)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "withImage" {
        }
    }
    
    @IBAction func NextPageButtonPressed(_ sender: AnyObject) {
        

        tableView.isHidden = true
        if self.condition == 2 {
        nextButton.isEnabled = false
            if self.newsList.count > 0 {
            deleteThings()
        TheNumberI! += 5
            UserDefaults.standard.set(TheNumberI, forKey: "TheNumberI")
        
        
        getNewsData()
            textField.placeholder = "\(self.TheNumberI/5+1)/\(self.TheDataNumber/5+1)"
            }else {
                TheNumberI! += 5
                UserDefaults.standard.set(TheNumberI, forKey: "TheNumberI")
                getNewsData()
            }

        }else {
            print("you are reaching the last page")
            
        }
        tableView.setContentOffset(CGPoint.zero, animated: true)
    }
    
    @IBAction func PreviousPageButtonPressed(_ sender: AnyObject) {
        
        previousButton.isEnabled = false
            deleteThings()

        if TheNumberI >= 5 {
        TheNumberI! -= 5
            
        UserDefaults.standard.set(TheNumberI, forKey: "TheNumberI")
            getNewsData()
            textField.placeholder = "\(self.TheNumberI/5+1)/\(self.TheDataNumber/5+1)"
        }else{
            print("Reaching the first page")
        }
        tableView.setContentOffset(CGPoint.zero, animated: true)
        
    }
    
    @IBAction func GoButtonPressed(_ sender: AnyObject) {
        
        if textField.text?.isEmpty == true {
            print("Please enter a number")
        }else if Int(textField.text!)!*5-5 > self.TheDataNumber {
            print("cannot go that far")
        }else {
            deleteThings()
            self.TheNumberI = Int(textField.text!)! * 5 - 5
            UserDefaults.standard.set(TheNumberI, forKey: "TheNumberI")
            textField.placeholder = "\(self.TheNumberI/5+1)/\(self.TheDataNumber/5+1)"
            getNewsData()
            textField.text?.removeAll()
            tableView.setContentOffset(CGPoint.zero, animated: true)
        }
    }
    
}



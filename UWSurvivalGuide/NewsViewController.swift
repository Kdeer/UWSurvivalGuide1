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
        return (UIApplication.sharedApplication().delegate as! AppDelegate).refresh
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.automaticallyAdjustsScrollViewInsets = false
        tableView.delegate = self
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 400
        textField.delegate = self 
        (UIApplication.sharedApplication().delegate as! AppDelegate).myViewController = self
        
        fetchAndLoad()

    }
    
    override func viewWillAppear(animated: Bool) {
        print("in view Will Appear")
        print(refresh)
        subscribeToKeyboardNotifications()

        print("the newListNumber is \(self.newsList.count)")
        print("theNumberI's number is \(self.TheNumberI)")
        print("TheDataNumber number is \(self.TheDataNumber)")
        print("The condition Number is \(self.condition)")
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        unsubscribeFromKeyboardNotifications()
    }
    

    
    func fetchAndLoad() {
        freshingIndicator.hidden = true
        if refresh == true {
            
            tableView.hidden = true
            freshingIndicator.hidden = false
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
            self.TheNumberI = NSUserDefaults.standardUserDefaults().integerForKey("TheNumberI")
            self.condition = NSUserDefaults.standardUserDefaults().integerForKey("condition")
            self.TheDataNumber = NSUserDefaults.standardUserDefaults().integerForKey("TheDataNumber")
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
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.newsList.count
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as! NewsTableViewCell
        cell.indicator.hidden = true
        if newsList.count > 0 {
        let newsRow = newsList[indexPath.row]
        cell.titleLabel.text = newsRow.title

        if newsRow.descriptions != nil{
            if let doc = HTML(html: newsRow.descriptions!, encoding: NSUTF8StringEncoding){
            let length = newsRow.descriptions.characters.count
            if length > 100 {
        cell.descriptionLabel.text = doc.content![0...100] + " ..."
        }else {
            cell.descriptionLabel.text = doc.content![0..<length-1]
            }
        }
        }else if newsRow.descriptions_raw != nil{
            if let doc = HTML(html: newsRow.descriptions_raw!, encoding: NSUTF8StringEncoding){
                
                let length = doc.content?.characters.count
                if length > 100 {
                    cell.descriptionLabel.text = doc.content![0...100] + " ..."
                }else {
                    cell.descriptionLabel.text = doc.content![0..<length!-1]
                }
            }
            }
        
        
        
        var posterImage = UIImage(named: "campus bubble")
        cell.newsImageView.contentMode = .ScaleAspectFit
            
            if newsRow.imageURL == nil || newsRow.imageURL == "" {
                posterImage = UIImage(named: "Campus Bubble")!
            }else if newsRow.newsImage != nil {
                posterImage = newsRow.newsImage!
            }else {
                cell.indicator.hidden = false
                cell.indicator.startAnimating()
                let task = UWSGFoodClientModel.sharedInstance().taskForImage(newsRow.imageURL) {(imageData, error) in
                    
                    if let data = imageData {
                        performUIUpdatesOnMain(){
                            newsRow.newsImage = UIImage(data: data)
                            tableView.reloadData()
                            cell.indicator.stopAnimating()
                            cell.indicator.hidden = true
                        }
                    }
                }
                
                    cell.taskToCancelifCellIsReused = task

        }

        
            cell.newsImageView.image = posterImage
    }

        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
//        let cell = tableView.cellForRowAtIndexPath(indexPath) as! NewsTableViewCell
        
        let newsRow = newsList[indexPath.row]

//        if newsRow.descriptions != nil {
//                self.descriptionString = newsRow.descriptions!
//            }else
            if newsRow.descriptions_raw != nil {
                        
            if let doc = HTML(html: newsRow.descriptions_raw!, encoding: NSUTF8StringEncoding){
                self.descriptionString = doc.content!
            }
                }else {
                    let app = UIApplication.sharedApplication()
                    if newsRow.link != nil {
                        app.openURL(NSURL(string: newsRow.link!)!)
            }
        }
        let time = "Published at " + self.timeCheck(newsRow.published) + ", Updated at \(self.timeCheck(newsRow.updatedAt))"
        if newsRow.imageURL != nil {
            let controller = self.storyboard!.instantiateViewControllerWithIdentifier("NewsDetailViewController") as! NewsDetailViewController
            controller.titleLabelText = newsRow.title
            controller.timeLabelText = time
            controller.descriptionString = self.descriptionString

            controller.imageURL = newsRow.imageURL
            controller.newsList = newsRow

            self.navigationController!.pushViewController(controller, animated: true)
        }else {
            let controller = self.storyboard!.instantiateViewControllerWithIdentifier("NewsDetailViewController1") as! NewsDetailViewController1
            controller.titleLabelText = newsRow.title
            controller.timeLabelText = time
            controller.descriptionString = self.descriptionString
            self.navigationController!.pushViewController(controller, animated: true)
        }
        
        timeCheck(newsRow.updatedAt)
    }
    
    @IBAction func NextPageButtonPressed(sender: AnyObject) {
        

        tableView.hidden = true
        if self.condition == 2 {
        nextButton.enabled = false
            if self.newsList.count > 0 {
            deleteThings()
        TheNumberI! += 5
            NSUserDefaults.standardUserDefaults().setInteger(TheNumberI, forKey: "TheNumberI")
        
        
        getNewsData()
            textField.placeholder = "\(self.TheNumberI/5+1)/\(self.TheDataNumber/5+1)"
            }else {
                TheNumberI! += 5
                NSUserDefaults.standardUserDefaults().setInteger(TheNumberI, forKey: "TheNumberI")
                getNewsData()
            }

        }else {
            print("you are reaching the last page")
            
        }
        tableView.setContentOffset(CGPointZero, animated: true)
    }
    
    @IBAction func PreviousPageButtonPressed(sender: AnyObject) {
        
        previousButton.enabled = false
            deleteThings()

        if TheNumberI >= 5 {
        TheNumberI! -= 5
            
        NSUserDefaults.standardUserDefaults().setInteger(TheNumberI, forKey: "TheNumberI")
            getNewsData()
            textField.placeholder = "\(self.TheNumberI/5+1)/\(self.TheDataNumber/5+1)"
        }else{
            print("Reaching the first page")
        }
        tableView.setContentOffset(CGPointZero, animated: true)
        
    }
    
    @IBAction func GoButtonPressed(sender: AnyObject) {
        
        if textField.text?.isEmpty == true {
            print("Please enter a number")
        }else if Int(textField.text!)!*5-5 > self.TheDataNumber {
            print("cannot go that far")
        }else {
            deleteThings()
            self.TheNumberI = Int(textField.text!)! * 5 - 5
            NSUserDefaults.standardUserDefaults().setInteger(TheNumberI, forKey: "TheNumberI")
            textField.placeholder = "\(self.TheNumberI/5+1)/\(self.TheDataNumber/5+1)"
            getNewsData()
            textField.text?.removeAll()
            tableView.setContentOffset(CGPointZero, animated: true)
        }
    }
    
}



//
//  EventViewController.swift
//  UWSurvivalGuide
//
//  Created by Xiaochao Luo on 2016-07-15.
//  Copyright © 2016 Xiaochao Luo. All rights reserved.
//

import UIKit
import Foundation
import CoreData


class EventViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchResultsUpdating {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    
    var allEventList = [AllEvent]()
    var allTimes = [TimeDict]()
    var sectionName = [String]()
    var sectionTitle = [[String]]()
    var sectionType = [[String]]()
    var sectionTime = [[String]]()
    var EventDetailList = [EventDetail]()
    var expectedList = [ExpectedEvent]()
    var whetherOrNot = [Bool]()
    var allTime = [String]()
    var allTime1 = [String]()
    var resultSearchController: UISearchController!
    var filteredResults = [String]()
    var searchedResultsArray = [String]()
    var expiredOrNot = [Bool]()
    
    override func viewDidLoad() {

        tableView.delegate = self
        tableView.contentInset = UIEdgeInsetsZero
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 400
        
        resultSearchingController()
    }
    
    func resultSearchingController(){
        resultSearchController = UISearchController(searchResultsController: nil)
        resultSearchController.searchResultsUpdater = self
        resultSearchController.hidesNavigationBarDuringPresentation = false
        resultSearchController.dimsBackgroundDuringPresentation = false
        resultSearchController.searchBar.sizeToFit()
        
        tableView.tableHeaderView = resultSearchController.searchBar
        
        self.definesPresentationContext = true
        self.automaticallyAdjustsScrollViewInsets = false
    }
    
    
    override func viewWillAppear(animated: Bool) {
        howManyExpected()

    }
    
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        filteredResults.removeAll(keepCapacity: false)
        let searchPredicate = NSPredicate(format: "SELF CONTAINS[c] %@", searchController.searchBar.text!)
        let array = (self.searchedResultsArray as NSArray).filteredArrayUsingPredicate(searchPredicate)
        filteredResults = array as! [String]
        
        tableView.reloadData()
    }
    
    func howManyExpected(){
        expectedList = fetchExpectedEvents()
        allEventList.removeAll()
        whetherOrNot.removeAll()
        
        getEventData()

    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if resultSearchController.active {
            return ""
        } else {
        return sectionName[section]
        }
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        if resultSearchController.active {
            return filteredResults.count
        }else {
        
        return sectionName.count
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if resultSearchController.active {
            return filteredResults.count
        }else {
        return sectionTime[section].count
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as! EventTableViewCell

        if resultSearchController.active{
            print(self.filteredResults.count)
            cell.titleLabel?.text = self.filteredResults[indexPath.row]
            cell.typeLabel.hidden = true
            cell.timeLabel.hidden =  true
            cell.expectedButton.hidden = true
            return cell
        }else {
        
        cell.typeLabel.hidden = false
            cell.timeLabel.hidden = false
        cell.titleLabel.text = sectionTitle[indexPath.section][0]
        for i in 0...sectionType.count - 1 {
            if sectionType[i].isEmpty == true {
                sectionType[i] = ["Not Attributed"]
            }
        }
        cell.typeLabel.text = "Type:" + " " + sectionType[indexPath.section][0]
        
        if indexPath.row > 0 {
            cell.titleLabel.text = ""
            cell.typeLabel.text = ""
        }
        
        if expectedList.isEmpty == false && allEventList.isEmpty == false {
            cell.expectedButton.hidden = !whetherOrNot[indexPath.section]
        }
        
        cell.timeLabel.text = sectionTime[indexPath.section][indexPath.row]
            
            cell.expiredLabel.hidden = !expiredOrNot[indexPath.section]
            cell.expiredLabel.textColor = UIColor.redColor()
            cell.expiredLabel.text = "Expired"
            cell.expiredLabel.font = UIFont(name: (cell.expiredLabel?.font?.fontName)!, size: 40)
        
        return cell
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        if resultSearchController.active {
            resultSearchController.dismissViewControllerAnimated(true, completion: nil)
            resultSearchController.active = false
            let controller = self.storyboard!.instantiateViewControllerWithIdentifier("EventDetailViewController") as! EventDetailViewController
            if self.allEventList.count > 0 {
            for i in 0...allEventList.count - 1 {
                if filteredResults[indexPath.row] == allEventList[i].title {
                    let site = allEventList[i].site
                    let id = allEventList[i].id

                    controller.eventDetail = self.allEventList[i]
                    controller.eventSite = site
                    controller.eventID = id
                    controller.times = sectionTime[i][0]
                    controller.isExpected = whetherOrNot[i]
                    controller.isExpired = expiredOrNot[i]
                }
                }
                self.presentViewController(controller, animated: true, completion: nil)
            }
        }else {
        
            if allEventList.count > 0 {
        let site = allEventList[indexPath.section].site
        let id = allEventList[indexPath.section].id
        let controller = self.storyboard!.instantiateViewControllerWithIdentifier("EventDetailViewController") as! EventDetailViewController
        controller.eventDetail = self.allEventList[indexPath.section]
        controller.eventSite = site
        controller.eventID = id
        controller.times = sectionTime[indexPath.section][indexPath.row]
        controller.isExpired = expiredOrNot[indexPath.section]
        controller.isExpected = whetherOrNot[indexPath.section]
        self.presentViewController(controller, animated: true, completion: nil)
        }
        }
    }
    
    func getEventData(){
        tableView.hidden = true
        indicator.startAnimating()
        UWSGFoodClientModel.sharedInstance().taskForGetMethod("events.json", parameters: [:]){(result, error) in
            
            if error == nil {
                performUIUpdatesOnMain(){
                if let data = result["data"] as? [[String:AnyObject]] {
                    for item in data {
                        self.allEventList.append(AllEvent(dictionary: item))
                    }
                    }
                    self.expiredOrNot.removeAll()
                    while self.whetherOrNot.count < self.allEventList.count {
                        self.whetherOrNot.append(false)
                        self.expiredOrNot.append(false)
                    }
                    print(self.whetherOrNot.count, self.sectionName.count, self.expiredOrNot.count)
                    
                    self.sectionTime.removeAll()
                    self.sectionType.removeAll()
                    self.sectionTitle.removeAll()
                    self.sectionName.removeAll()
                    self.searchedResultsArray.removeAll()
                for i in 0...self.allEventList.count-1{
                    self.sectionName.append(self.allEventList[i].site_name)
                    self.sectionTitle.append([self.allEventList[i].title])
                    self.searchedResultsArray.append(self.allEventList[i].title)
                    self.sectionType.append(self.allEventList[i].type)
                    
                    for d in 0...self.allEventList[i].times.count - 1 {

                    self.allTime.append(self.allEventList[i].times[d]["start"]!)
                    }
                    if self.allTime.count > 1 {
                    self.allTime1.append(self.allTime[0] + " To " + self.allTime.last!)
                        self.expiredOrNot[i] = self.expireCheck(self.allTime.last!)
                    }else {
                        self.allTime1 = self.allTime
                        self.expiredOrNot[i] = self.expireCheck(self.allTime[0])
                        
                    }
                    self.sectionTime.append(self.allTime1)
                    self.allTime1.removeAll()
                    self.allTime.removeAll()

                    }
                    
                    self.rangeToRemove()
                self.tableView.reloadData()
                    self.indicator.hidden = true
                    self.indicator.stopAnimating()
                    self.tableView.hidden = false
                }
            }else {
                let alertController = UIAlertController(title: "Oops!", message: "There is a Network Error", preferredStyle: .Alert)
                let OkayAction = UIAlertAction(title: "Okay", style: .Default, handler: nil)
                alertController.addAction(OkayAction)
                self.presentViewController(alertController, animated: true, completion: nil)
                self.indicator.hidden = true
                self.indicator.stopAnimating()
            }
        }
    }
    
    
    //mark: expire events removal
    func rangeToRemove() {
        var rangeToRemove: Int! = 0
        
        if self.expiredOrNot.count > 0 {
            for i in 0...self.expiredOrNot.count - 1 {
                if self.expiredOrNot[i] == true {
                    rangeToRemove! += 1
                }
            }
        }
        self.sectionTitle.removeFirst(rangeToRemove)
        self.sectionType.removeFirst(rangeToRemove)
        self.sectionName.removeFirst(rangeToRemove)
        self.sectionTime.removeFirst(rangeToRemove)
        self.allEventList.removeFirst(rangeToRemove)
        self.expiredOrNot.removeFirst(rangeToRemove)
        self.whetherOrNot.removeFirst(rangeToRemove)
        self.searchedResultsArray.removeFirst(rangeToRemove)
        
        print(self.whetherOrNot.count, self.sectionName.count, self.expiredOrNot.count)
        
        if self.allEventList.count > 0 {
            for i in 0...self.allEventList.count - 1 {
                if self.expectedList.count > 0 {
                    for d in 0...self.expectedList.count - 1 {
                        if self.allEventList[i].id == self.expectedList[d].id {
                            self.whetherOrNot[i] = true
                        }
                    }
                }
            }
        }
    }




    func expireCheck(theTime: String) -> Bool {
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZ"
        dateFormatter.dateFromString(theTime)
        let theDate = dateFormatter.dateFromString(theTime)
        let calendar = NSCalendar.currentCalendar()
        let components1 = calendar.components([.Day, .Month, .Year], fromDate: theDate!)
        let yearEvent = components1.year
        let monthEvent = components1.month
        let dayEvent = components1.day
        
        let date = NSDate()
        let components = calendar.components([.Day, .Month, .Year], fromDate: date)
        let yearNow = components.year
        let monthNow = components.month
        let dayNow = components.day
        
        if yearNow > yearEvent || (yearNow == yearEvent && monthNow > monthEvent) || (yearNow == yearEvent && monthNow == monthEvent && dayNow > dayEvent){
            
            return true
        }else {
            return false
        }
    }

}

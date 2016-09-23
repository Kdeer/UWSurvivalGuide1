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
        tableView.contentInset = UIEdgeInsets.zero
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
    
    
    override func viewWillAppear(_ animated: Bool) {
        howManyExpected()

    }
    
    func updateSearchResults(for searchController: UISearchController) {
        filteredResults.removeAll(keepingCapacity: false)
        let searchPredicate = NSPredicate(format: "SELF CONTAINS[c] %@", searchController.searchBar.text!)
        let array = (self.searchedResultsArray as NSArray).filtered(using: searchPredicate)
        filteredResults = array as! [String]
        
        tableView.reloadData()
    }
    
    func howManyExpected(){
        expectedList = fetchExpectedEvents()
        allEventList.removeAll()
        whetherOrNot.removeAll()
        
        getEventData()

    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if resultSearchController.isActive {
            return ""
        } else {
        return sectionName[section]
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        if resultSearchController.isActive {
            return filteredResults.count
        }else {
        
        return sectionName.count
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if resultSearchController.isActive {
            return filteredResults.count
        }else {
        return sectionTime[section].count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! EventTableViewCell

        if resultSearchController.isActive{
            print(self.filteredResults.count)
            cell.titleLabel?.text = self.filteredResults[(indexPath as NSIndexPath).row]
            cell.typeLabel.isHidden = true
            cell.timeLabel.isHidden =  true
            cell.expectedButton.isHidden = true
            return cell
        }else {
        
        cell.typeLabel.isHidden = false
            cell.timeLabel.isHidden = false
        cell.titleLabel.text = sectionTitle[(indexPath as NSIndexPath).section][0]
        for i in 0...sectionType.count - 1 {
            if sectionType[i].isEmpty == true {
                sectionType[i] = ["Not Attributed"]
            }
        }
        cell.typeLabel.text = "Type:" + " " + sectionType[(indexPath as NSIndexPath).section][0]
        
        if (indexPath as NSIndexPath).row > 0 {
            cell.titleLabel.text = ""
            cell.typeLabel.text = ""
        }
        
        if expectedList.isEmpty == false && allEventList.isEmpty == false {
            cell.expectedButton.isHidden = !whetherOrNot[(indexPath as NSIndexPath).section]
        }
        
        cell.timeLabel.text = sectionTime[(indexPath as NSIndexPath).section][(indexPath as NSIndexPath).row]
            
            cell.expiredLabel.isHidden = !expiredOrNot[(indexPath as NSIndexPath).section]
            cell.expiredLabel.textColor = UIColor.red
            cell.expiredLabel.text = "Expired"
            cell.expiredLabel.font = UIFont(name: (cell.expiredLabel?.font?.fontName)!, size: 40)
        
        return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if resultSearchController.isActive {
            resultSearchController.dismiss(animated: true, completion: nil)
            resultSearchController.isActive = false
            let controller = self.storyboard!.instantiateViewController(withIdentifier: "EventDetailViewController") as! EventDetailViewController
            if self.allEventList.count > 0 {
            for i in 0...allEventList.count - 1 {
                if filteredResults[(indexPath as NSIndexPath).row] == allEventList[i].title {
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
                self.present(controller, animated: true, completion: nil)
            }
        }else {
        
            if allEventList.count > 0 {
        let site = allEventList[(indexPath as NSIndexPath).section].site
        let id = allEventList[(indexPath as NSIndexPath).section].id
        let controller = self.storyboard!.instantiateViewController(withIdentifier: "EventDetailViewController") as! EventDetailViewController
        controller.eventDetail = self.allEventList[(indexPath as NSIndexPath).section]
        controller.eventSite = site
        controller.eventID = id
        controller.times = sectionTime[(indexPath as NSIndexPath).section][(indexPath as NSIndexPath).row]
        controller.isExpired = expiredOrNot[(indexPath as NSIndexPath).section]
        controller.isExpected = whetherOrNot[(indexPath as NSIndexPath).section]
        self.present(controller, animated: true, completion: nil)
        }
        }
    }
    
    func getEventData(){
        tableView.isHidden = true
        indicator.startAnimating()
        UWSGFoodClientModel.sharedInstance().taskForGetMethod("events.json", parameters: [:]){(result, error) in
            
            if error == nil {
                performUIUpdatesOnMain(){
                if let data = result?["data"] as? [[String:AnyObject]] {
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
                    self.indicator.isHidden = true
                    self.indicator.stopAnimating()
                    self.tableView.isHidden = false
                }
            }else {
                let alertController = UIAlertController(title: "Oops!", message: "There is a Network Error", preferredStyle: .alert)
                let OkayAction = UIAlertAction(title: "Okay", style: .default, handler: nil)
                alertController.addAction(OkayAction)
                self.present(alertController, animated: true, completion: nil)
                self.indicator.isHidden = true
                self.indicator.stopAnimating()
            }
        }
    }
    
    
    //mark: expire events removal
    func rangeToRemove() {
        print(allEventList[0])
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
        
        if self.allEventList.count > 0 && self.expectedList.count > 0 {
            for i in 0...self.allEventList.count - 1  {
                    for d in 0...self.expectedList.count - 1 {
                        
                        if Int(allEventList[i].id) == Int(expectedList[d].id){
                            self.whetherOrNot[i] = true
                        }
                        
                        
                        
//                        if self.allEventList[i].id == self.expectedList[d].id {
//                            self.whetherOrNot[i] = true
//                        }
                
                }
            }
        }
    }



    func expireCheck(_ theTime: String) -> Bool {
        
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZ"
        dateFormatter.date(from: theTime)
        let theDate = dateFormatter.date(from: theTime)
        let calendar = Calendar.current
        let components1 = (calendar as NSCalendar).components([.day, .month, .year], from: theDate!)
        let yearEvent = components1.year
        let monthEvent = components1.month
        let dayEvent = components1.day
        
        let date = Date()
        let components = (calendar as NSCalendar).components([.day, .month, .year], from: date)
        let yearNow = components.year
        let monthNow = components.month
        let dayNow = components.day
        
        if yearNow! > yearEvent! || (yearNow! == yearEvent! && monthNow! > monthEvent!) || (yearNow! == yearEvent! && monthNow! == monthEvent! && dayNow! > dayEvent!){
            
            return true
        }else {
            return false
        }
    }

}

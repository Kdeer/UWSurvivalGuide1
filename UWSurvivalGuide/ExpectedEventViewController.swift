//
//  ExpectedEventViewController.swift
//  UWSurvivalGuide
//
//  Created by Xiaochao Luo on 2016-07-19.
//  Copyright © 2016 Xiaochao Luo. All rights reserved.
//

import UIKit
import CoreData

class ExpectedEventViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    
    var ExpectedEventList = [ExpectedEvent]()
    var sectionTitle = [[String]]()
    var sectionTime = [[String]]()
    var sectionType = [[String]]()
    var sectionName = [String]()
    var expiredOrNot = [Bool]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.automaticallyAdjustsScrollViewInsets = false
        self.tableView.delegate = self
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 400
    }
    

    
    func fetchAndLoad(){
        
        self.ExpectedEventList = fetchExpectedEvents()
        
        self.sectionTitle.removeAll()
        self.sectionType.removeAll()
        self.sectionTime.removeAll()
        self.sectionName.removeAll()
        
        if ExpectedEventList.count > 0 {
            
            while expiredOrNot.count < ExpectedEventList.count {
                expiredOrNot.append(false)
            }
            
        for i in 0...ExpectedEventList.count - 1 {
            
            
            self.sectionTime.append([self.ExpectedEventList[i].times ?? "Time is not available"])
            self.sectionType.append([self.ExpectedEventList[i].type ?? "Not Attributed"])
            self.sectionTitle.append([self.ExpectedEventList[i].title ?? "Title is Vacant"])
            self.sectionName.append(self.ExpectedEventList[i].site_name)
        }
        }
        
        if self.sectionTime.count > 0 {
        for i in 0...self.sectionTime.count - 1 {
            if self.sectionTime[i][0].rangeOfString("To")?.isEmpty == false {
                let fullTime = self.sectionTime[i][0]
                let fullTimeArr = fullTime.componentsSeparatedByString("To ")
                self.expiredOrNot[i] = expireCheck(fullTimeArr[1])
            }else {
                self.expiredOrNot[i] = expireCheck(self.sectionTime[i][0])
            }
        }
        }
        
        tableView.reloadData()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        fetchAndLoad()
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sectionName[section]
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return sectionName.count
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sectionTitle[section].count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as! EventTableViewCell
        cell.exTimeLabel.text = sectionTime[indexPath.section][indexPath.row]
        cell.exTypeLabel.text = sectionType[indexPath.section][indexPath.row]
        cell.exTitleLabel.text = sectionTitle[indexPath.section][indexPath.row]
        cell.expiredLabel1.hidden = !self.expiredOrNot[indexPath.section]
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let controller = self.storyboard!.instantiateViewControllerWithIdentifier("EventDetailViewController") as! EventDetailViewController
        let site = ExpectedEventList[indexPath.section].site
        let id = ExpectedEventList[indexPath.section].id
        controller.eventSite = site
        controller.eventID = Int(id)
        controller.link = ExpectedEventList[indexPath.section].link
        controller.isExpired = self.expiredOrNot[indexPath.section]
        controller.isExpected = true
        self.presentViewController(controller, animated: true, completion: nil)
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        
        if editingStyle == .Delete{
            
            self.tableView.beginUpdates()
            let indexSet = NSMutableIndexSet()
            indexSet.addIndex(indexPath.section)

            sharedContext.deleteObject(self.ExpectedEventList[indexPath.section])
            self.ExpectedEventList.removeAtIndex(indexPath.section)
            
            self.sectionName.removeAtIndex(indexPath.section)
                self.sectionTime.removeAtIndex(indexPath.section)
                self.sectionType.removeAtIndex(indexPath.section)
                self.sectionTitle.removeAtIndex(indexPath.section)

            tableView.deleteSections(indexSet, withRowAnimation: .Fade)
            saveContext()
            tableView.endUpdates()
            
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

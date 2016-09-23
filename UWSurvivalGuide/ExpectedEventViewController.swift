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
            if self.sectionTime[i][0].range(of: "To")?.isEmpty == false {
                let fullTime = self.sectionTime[i][0]
                let fullTimeArr = fullTime.components(separatedBy: "To ")
                self.expiredOrNot[i] = expireCheck(fullTimeArr[1])
            }else {
                self.expiredOrNot[i] = expireCheck(self.sectionTime[i][0])
            }
        }
        }
        
        tableView.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchAndLoad()
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sectionName[section]
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return sectionName.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sectionTitle[section].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! EventTableViewCell
        cell.exTimeLabel.text = sectionTime[(indexPath as NSIndexPath).section][(indexPath as NSIndexPath).row]
        cell.exTypeLabel.text = sectionType[(indexPath as NSIndexPath).section][(indexPath as NSIndexPath).row]
        cell.exTitleLabel.text = sectionTitle[(indexPath as NSIndexPath).section][(indexPath as NSIndexPath).row]
        cell.expiredLabel1.isHidden = !self.expiredOrNot[(indexPath as NSIndexPath).section]
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let controller = self.storyboard!.instantiateViewController(withIdentifier: "EventDetailViewController") as! EventDetailViewController
        let site = ExpectedEventList[(indexPath as NSIndexPath).section].site
        let id = ExpectedEventList[(indexPath as NSIndexPath).section].id
        controller.eventSite = site
        controller.eventID = Int(id!)
        controller.link = ExpectedEventList[(indexPath as NSIndexPath).section].link
        controller.isExpired = self.expiredOrNot[(indexPath as NSIndexPath).section]
        controller.isExpected = true
        self.present(controller, animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete{
            
            self.tableView.beginUpdates()
            let indexSet = NSMutableIndexSet()
            indexSet.add((indexPath as NSIndexPath).section)

            sharedContext.delete(self.ExpectedEventList[(indexPath as NSIndexPath).section])
            self.ExpectedEventList.remove(at: (indexPath as NSIndexPath).section)
            
            self.sectionName.remove(at: (indexPath as NSIndexPath).section)
                self.sectionTime.remove(at: (indexPath as NSIndexPath).section)
                self.sectionType.remove(at: (indexPath as NSIndexPath).section)
                self.sectionTitle.remove(at: (indexPath as NSIndexPath).section)

            tableView.deleteSections(indexSet as IndexSet, with: .fade)
            saveContext()
            tableView.endUpdates()
            
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

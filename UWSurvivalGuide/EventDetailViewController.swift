//
//  EventDetailViewController.swift
//  UWSurvivalGuide
//
//  Created by Xiaochao Luo on 2016-07-18.
//  Copyright © 2016 Xiaochao Luo. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class EventDetailViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var eventNameLabel: UILabel!
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var expectButton: UIBarButtonItem!

    
    
    var eventDetail: AllEvent!
    var eventID: Int!
    var eventSite: String!
    var EventTimeList = [EventTime]()
    var descriptions: String? = nil
    var audience: [String] = []
    var audiences: String? = nil
    var eventCost: String? = nil
    var location: [String:AnyObject]!
    var eventLocation: EventLocation!
    var eventLocations = [EventLocation]()
    var expectedEventsList = [ExpectedEvent]()
    var times: String? = nil
    var titleString: String? = nil
    var link: String? = nil
    var isExpired: Bool? = false
    var isExpected: Bool? = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.automaticallyAdjustsScrollViewInsets = false
        tableView.delegate = self
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 400
        
        if isExpected == true {
            self.expectButton.tintColor = UIColor.yellowColor()
//            self.expectButton.enabled = false
        }else {
            self.expectButton.enabled = true
        }
        getEventDetail(eventSite, id: eventID)
        
       // self.view.backgroundColor = UIColor(patternImage: UIImage(named: "background")!)
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell1", forIndexPath: indexPath) as! EventTableViewCell
        
        cell.expireLabel.hidden = !isExpired!
        if EventTimeList.count == 1 {
        cell.eventTimeLabel.text = EventTimeList[0].start_date + " " + EventTimeList[0].start_day + " " + EventTimeList[0].start_time
        }else if EventTimeList.count > 1 {
            cell.eventTimeLabel.text = EventTimeList[0].start_date + " " + EventTimeList[0].start_day + " " + EventTimeList[0].start_time + " and so on, please check link for more info"
        }
        
        if self.descriptions == nil {
            cell.DescriptionLabel.text = "Null"
            cell.DescriptionLabel.textAlignment = .Left
        }else {
            cell.DescriptionLabel.text = self.descriptions
        }
        
        if self.audience.count > 0 {
        
            audiences = self.audience.joinWithSeparator(", ")
            print(self.audiences)
            cell.audienceLabel.text = self.audiences
        }else {
           cell.audienceLabel.text = "See Links Below"
        }
        
        if self.eventCost == nil {
            cell.costLabel.text = "Not Specified, Normally that means free, click the link for more infos"
        }else {
            cell.costLabel.text = self.eventCost
        }
        
        if eventLocation != nil {
            cell.locationInfoLabel.text = locationString()
            if eventLocation!.latitude == nil {
                cell.directionButton.hidden = true
            }else {
                cell.directionButton.addTarget(self, action: #selector(EventDetailViewController.getDirection(_:)), forControlEvents: UIControlEvents.TouchUpInside)
                print("not nil")
            }
        }
        

        
    
        cell.eventTimeLabel.textColor = UIColor(red: 114 / 255, green: 114 / 255, blue: 114 / 255, alpha: 1.0)
        
        return cell
    }
    
    func locationString() -> String{
        
        let firstCommaSpace = (eventLocation.name != nil) ? ", " : ""
        let secondCommaSpace = (eventLocation.additional != nil) ? ", " : ""
        let thirdCommaSpace = (eventLocation.street != nil) ? ", " : ""
        let fourthCommaSpace = (eventLocation.city != nil) ? ", " : ""
        let addressLine = String(
            
        format: "%@%@%@%@%@%@%@%@%@",
        
        eventLocation.additional ?? "",
        secondCommaSpace,
        eventLocation.name ?? "",
        firstCommaSpace,
        eventLocation.street ?? "",
        thirdCommaSpace,
        eventLocation.city ?? "",
        fourthCommaSpace,
        
        eventLocation.postal_code ?? ""
        )
        
        return addressLine
    }
    
    @IBAction func LinkButtonPressed(sender: AnyObject) {
        
        let app = UIApplication.sharedApplication()
        if self.link != nil {
        app.openURL(NSURL(string: self.link!)!)
        }else {
            app.openURL(NSURL(string: self.eventDetail.link)!)
        }
    }
    
    
    func getDirection(sender: UIButton){
        let controller = self.storyboard!.instantiateViewControllerWithIdentifier("ParkingLocationViewController") as! ParkingLocationViewController
        controller.latitude = eventLocation!.latitude
        controller.longitude = eventLocation!.longitude
        if eventLocation!.name != nil {
        controller.titles = eventLocation!.name
        }

        self.presentViewController(controller, animated: true, completion: nil)
        
    }
    
    @IBAction func DismissButtonPressed(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    

    @IBAction func ExpectedEventButtonPressed(sender: AnyObject) {
        
        if isExpected == false {
        let dictionary: [String:AnyObject] = [
            
            "id": self.eventDetail.id!,
            "site": self.eventDetail.site!,
            "site_name": self.eventDetail.site_name!,
            "link": self.eventDetail.link!,
            "times": self.times!,
            "title": self.eventDetail.title!,
            "type": self.eventDetail.type!,
            "isExpired": self.isExpired!
        ]
        
        let event = ExpectedEvent(dictionary: dictionary, context: sharedContext)
        expectedEventsList.append(event)
        saveContext()
            isExpected = true
            self.expectButton.tintColor = UIColor.yellowColor()
        }
    }
    
    
    func getEventDetail(site: String, id: Int) {
        
        UWSGFoodClientModel.sharedInstance().taskForGetMethod("events/\(site)/\(id).json", parameters: [:]){(result, error) in
            
            if error == nil {
                performUIUpdatesOnMain(){
                    if let data = result["data"] as? [String:AnyObject]{
                        let timeList = data["times"] as? [[String:AnyObject]]
                        
                        self.descriptions = data["description"] as? String
                        self.audience.removeAll()
                        self.audience = (data["audience"] as? [String])!
                        self.eventCost = data["cost"] as? String
                        let location = data["location"] as? [String:AnyObject]
//                        self.location = location
                        let locationInfo = location.map(){(dictionary:[String:AnyObject]) -> EventLocation in
                            let locationInfo = EventLocation(dictionary: dictionary)
                            return locationInfo
                        }
                        let title = data["title"] as? String
                        self.titleString = title
                        self.eventLocation = locationInfo!
                        self.EventTimeList.removeAll()
                        for item in timeList!{
                            self.EventTimeList.append(EventTime(dictionary: item))
                        }
                        //                    for item in data {
                        //                        self.EventDetailList.append(EventDetail(dictionary: item))
                        //                    }
                    }
                    
                    if self.titleString?.characters.count < 70 {
                    self.eventNameLabel.text = self.titleString
                    } else {
                        self.eventNameLabel.text = "Title is too long for display"
                        self.eventNameLabel.textColor = UIColor.blueColor()
                    }
                    self.tableView.reloadData()
                }
            }else{
                print("something is wrong")
            }
            
        }
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    
    
    
}
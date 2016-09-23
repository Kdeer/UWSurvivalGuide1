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
            self.expectButton.tintColor = UIColor.yellow
//            self.expectButton.enabled = false
        }else {
            self.expectButton.isEnabled = true
        }
        getEventDetail(eventSite, id: eventID)
        
       // self.view.backgroundColor = UIColor(patternImage: UIImage(named: "background")!)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell1", for: indexPath) as! EventTableViewCell
        
        cell.expireLabel.isHidden = !isExpired!
        if EventTimeList.count == 1 {
        cell.eventTimeLabel.text = EventTimeList[0].start_date + " " + EventTimeList[0].start_day + " " + EventTimeList[0].start_time
        }else if EventTimeList.count > 1 {
            cell.eventTimeLabel.text = EventTimeList[0].start_date + " " + EventTimeList[0].start_day + " " + EventTimeList[0].start_time + " and so on, please check link for more info"
        }
        
        if self.descriptions == nil {
            cell.DescriptionLabel.text = "Null"
            cell.DescriptionLabel.textAlignment = .left
        }else {
            cell.DescriptionLabel.text = self.descriptions
        }
        
        if self.audience.count > 0 {
        
            audiences = self.audience.joined(separator: ", ")
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
                cell.directionButton.isHidden = true
            }else {
                cell.directionButton.addTarget(self, action: #selector(EventDetailViewController.getDirection(_:)), for: UIControlEvents.touchUpInside)
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
    
    @IBAction func LinkButtonPressed(_ sender: AnyObject) {
        
        let app = UIApplication.shared
        if self.link != nil {
        app.openURL(URL(string: self.link!)!)
        }else {
            app.openURL(URL(string: self.eventDetail.link)!)
        }
    }
    
    
    func getDirection(_ sender: UIButton){
        let controller = self.storyboard!.instantiateViewController(withIdentifier: "ParkingLocationViewController") as! ParkingLocationViewController
        controller.latitude = eventLocation!.latitude
        controller.longitude = eventLocation!.longitude
        if eventLocation!.name != nil {
        controller.titles = eventLocation!.name
        }

        self.present(controller, animated: true, completion: nil)
        
    }
    
    @IBAction func DismissButtonPressed(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }
    
    

    @IBAction func ExpectedEventButtonPressed(_ sender: AnyObject) {
        
        if isExpected == false {
        let dictionary: [String:AnyObject] = [
            
            "id": self.eventDetail.id! as AnyObject,
            "site": self.eventDetail.site! as AnyObject,
            "site_name": self.eventDetail.site_name! as AnyObject,
            "link": self.eventDetail.link! as AnyObject,
            "times": self.times! as AnyObject,
            "title": self.eventDetail.title! as AnyObject,
            "type": self.eventDetail.type! as AnyObject,
            "isExpired": self.isExpired! as AnyObject
        ]
        
        let event = ExpectedEvent(dictionary: dictionary, context: sharedContext)
        expectedEventsList.append(event)
        saveContext()
            isExpected = true
            self.expectButton.tintColor = UIColor.yellow
        }
    }
    
    
    func getEventDetail(_ site: String, id: Int) {
        
        UWSGFoodClientModel.sharedInstance().taskForGetMethod("events/\(site)/\(id).json", parameters: [:]){(result, error) in
            
            if error == nil {
                performUIUpdatesOnMain(){
                    if let data = result?["data"] as? [String:AnyObject]{
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
                        self.eventNameLabel.textColor = UIColor.blue
                    }
                    self.tableView.reloadData()
                }
            }else{
                print("something is wrong")
            }
            
        }
    }
    
    override var prefersStatusBarHidden : Bool {
        return true
    }
    
    
    
    
}

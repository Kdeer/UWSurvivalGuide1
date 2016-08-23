//
//  FoodOutletTableViewController.swift
//  UWSurvivalGuide
//
//  Created by Xiaochao Luo on 2016-07-02.
//  Copyright © 2016 Xiaochao Luo. All rights reserved.
//

import Foundation
import UIKit

class FoodOutletTableViewController: UIViewController, UITableViewDelegate,UITableViewDataSource {
    
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var outletLabel: UILabel!
    @IBOutlet weak var outletImage: UIImageView!
    @IBOutlet weak var directionButton: UIButton!
    
    var foodInfo: FoodDict!
    var outletService: [String] = []
    var textLabel: String? = nil
    var detailOutletImage: imageStruct!
    var locationInfo = [LocationDict]()
    var locationInfo1: LocationDict!
    var arrayForSection:[[String]] = [[]]

    var section = ["Building", "Description", "Open Hours","Service"]
    
    var weekOpeningHour : [String]? = []
    var theDaysInWeek = ["monday", "tuesday", "wednesday", "thursday", "friday", "saturday", "sunday"]
    
    //mark: Menu's property
    var weekMenu: [[MealsDict]] = []
    var mealsInfo: [MealsDict] = []
    var outlet_ID: Int? = nil
    var whichMeal: String? = nil
    
    var theWeek = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"]
    var newWeek: [String] = []
    var weekTime: String? = nil
    
    var codeForMenuIcon: String? = nil
    
    //mark: the function to append the array for table sections
    
    func iAppend(){
        arrayForSection.removeAll()
        arrayForSection.append([locationInfo1.building])
        arrayForSection.append([locationInfo1.description ?? "None"])
        scheduleDecipher(locationInfo1, day: theDaysInWeek)
        arrayForSection.append(weekOpeningHour!)
        if foodInfo != nil {
        arrayForSection.append(outletService)
        }else {
            self.section.removeLast()
        }
        
    }
    
    func scheduleDecipher(daySchedule:LocationDict!,day:[String]){
        
        let openTime = "opening_hour"
        let closeTime = "closing_hour"
        let isClosed = "is_closed"
        
        for item in 0...day.count-1 {
        let dayTime = daySchedule.opening_hours[day[item]] as? [String:AnyObject]
        let openingHour = dayTime![openTime] as? String
        let closingHour = dayTime![closeTime] as? String
        let Closed = dayTime![isClosed] as? Int
        
        if Closed == 0 {
            let theDay = OpenTimeFormat(day[item], string2: openingHour!, string3: closingHour!)
            weekOpeningHour?.append(theDay)
        }
        }
        
    }
    
    func OpenTimeFormat(string1: String, string2: String, string3: String) -> String {
        
        let ultiString = string1 + ":" + "   " + string2 + " " + "-" + " " + string3
        return ultiString
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mealType()
        iAppend()
        tableView.delegate = self
        self.automaticallyAdjustsScrollViewInsets = false
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 340
        outletImage.image = detailOutletImage.theIamge
        title = self.locationInfo1.outlet_name
        tableView.reloadData()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        weekOpeningHour?.removeAll()
        self.weekMenu = []
        self.newWeek = []
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return self.section[section]
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return self.section.count
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.arrayForSection[section].count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("foodOutletTableCell", forIndexPath: indexPath) as! FoodOutletTableViewCell
        let sectionContent = arrayForSection[indexPath.section][indexPath.row]
        cell.informationLabel.text = sectionContent
        if cell.informationLabel.text == locationInfo1.building {
            cell.directionButton.hidden = false
        }else {
            cell.directionButton.hidden = true
        }
        
        if cell.directionButton.hidden == false {
            cell.directionButton.addTarget(self, action: #selector(self.goForDirection(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        }
//        cell.textLabel?.text = sectionContent
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let cell = tableView.cellForRowAtIndexPath(indexPath) as! FoodOutletTableViewCell
        if cell.informationLabel.text == locationInfo1.building{
            let controller = self.storyboard!.instantiateViewControllerWithIdentifier("FoodLocationMapViewController") as! FoodLocationMapViewController
            controller.latitude = locationInfo1.latitude
            controller.longitude = locationInfo1.longitude
            controller.outletsTitle = locationInfo1.building
            self.navigationController!.pushViewController(controller, animated: true)
        }
        
        if cell.informationLabel.text?.rangeOfString("Service")?.isEmpty == false {
            self.whichMeal = cell.informationLabel.text
            detectTheMeal()
            findTheMenu()


        }
    }

    func goForDirection(sender: UIButton){
        let controller = self.storyboard!.instantiateViewControllerWithIdentifier("FoodLocationMapViewController") as! FoodLocationMapViewController
        controller.latitude = locationInfo1.latitude
        controller.longitude = locationInfo1.longitude
        controller.outletsTitle = locationInfo1.building
        self.navigationController!.pushViewController(controller, animated: true)
    }
    
    @IBAction func GoForLocation(sender: AnyObject) {

    }
    
    

    
    func findTheLocation(){
        UWSGFoodClientModel.sharedInstance().taskForGetMethod("foodservices/locations.json", parameters: [:]){(result,error) in
            
            if error != nil {
                print(error)
            }else {
                performUIUpdatesOnMain(){
                    print(result)
                    if let data = result["data"] as? [[String:AnyObject]] {
                        for item in data {
                            self.locationInfo.append(LocationDict(dictionary: item))
                        }
                        print(self.locationInfo)
                    }
                }

            }
        }
    }
    
    
    func mealType(){
        
        if foodInfo != nil {
        
        if foodInfo.has_breakfast == 1 && foodInfo.has_lunch == 1 && foodInfo.has_dinner == 1 {
            self.outletService = ["Breakfast Service","Lunch Service","Dinner Service"]
        }else if foodInfo.has_breakfast == 1 && foodInfo.has_lunch == 1 && foodInfo.has_dinner == 0 {
            self.outletService = ["Breakfast Service","Lunch Service"]
        }else if foodInfo.has_breakfast == 1 && foodInfo.has_lunch == 0 && foodInfo.has_dinner == 0 {
            self.outletService = ["Breakfast Service"]
        }else if foodInfo.has_breakfast == 0 && foodInfo.has_lunch == 1 && foodInfo.has_dinner == 0 {
            self.outletService = ["Lunch Service"]
        }else if foodInfo.has_breakfast == 0 && foodInfo.has_lunch == 1 && foodInfo.has_dinner == 1 {
            self.outletService = ["Lunch Service","Dinner Service"]
        }else if foodInfo.has_breakfast == 0 && foodInfo.has_lunch == 0 && foodInfo.has_dinner == 1 {
            self.outletService = ["Dinner Service"]
        }else if foodInfo.has_breakfast == 1 && foodInfo.has_lunch == 0 && foodInfo.has_dinner == 1 {
            self.outletService = ["Breakfast Service","Dinner Service"]
        }
    }
    }
    
}

//
//  VisitorParkingTableViewController.swift
//  UWSurvivalGuide
//
//  Created by Xiaochao Luo on 2016-07-10.
//  Copyright © 2016 Xiaochao Luo. All rights reserved.
//

import Foundation
import UIKit
import CoreData


class VisitorParkingTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource{
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var mapViewParking: UIBarButtonItem!
    
    var VisitorParkingList = [VisitorParking]()
    var sectionName = [String]()
    var sectionInfos = [[String]]()
    var sectionNotes = [[String]]()
    var refreshControl: UIRefreshControl!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        refreshControl = UIRefreshControl()
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to Refresh")
        refreshControl.addTarget(self, action: #selector(VisitorParkingTableViewController.refresh), forControlEvents: UIControlEvents.ValueChanged)
        tableView.addSubview(refreshControl)
        self.automaticallyAdjustsScrollViewInsets = false
        tableView.delegate = self
        tableView.scrollEnabled = true
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 340
        
        fetchAndDeploy()
    }
    
    func refresh(){
        if VisitorParkingList.count > 0 {
            for i in 0...VisitorParkingList.count - 1 {
                sharedContext.deleteObject(VisitorParkingList[i])

            }
            sectionName.removeAll()
            sectionInfos.removeAll()
            sectionNotes.removeAll()
            saveContext()
            VisitorParkingList.removeAll()
        }
        tableView.reloadData()
        getVisitorParking()
        refreshControl.endRefreshing()
    }
    
    
    func fetchAndDeploy(){
        VisitorParkingList = fetchAllVisitors()
        
        if VisitorParkingList.count > 0 {
        for i in 0...VisitorParkingList.count-1{
            self.sectionName.append(VisitorParkingList[i].lot_name)
            self.sectionInfos.append([VisitorParkingList[i].descriptions])
            self.sectionNotes.append([VisitorParkingList[i].note])
        }
            self.tableView.reloadData()
        }else {
            getVisitorParking()
        }
        
    }
    
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Lot" + " " + sectionName[section]
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return sectionName.count
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sectionInfos[section].count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as! MeterParkingTableViewCell
        cell.visitorParkingLabel.text = sectionInfos[indexPath.section][indexPath.row]
        cell.visitorParkingNote.text = "Note:" + " " + sectionNotes[indexPath.section][indexPath.row]
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let controller = self.storyboard!.instantiateViewControllerWithIdentifier("ParkingLocationViewController") as! ParkingLocationViewController
        print(VisitorParkingList[indexPath.row])
        controller.visitorParking = self.VisitorParkingList[indexPath.section]
        
//        self.navigationController!.pushViewController(controller, animated: true)
        self.presentViewController(controller, animated: true, completion: nil)

    }
    
    @IBAction func MapVersionButton(sender: AnyObject) {
        let controller = self.storyboard!.instantiateViewControllerWithIdentifier("MapParkingLocationViewController") as! MapParkingLocationViewController
        controller.visitorParkingList = self.VisitorParkingList
        controller.initParkingIndicator = "Visitor"
        self.presentViewController(controller, animated: true, completion: nil)
        
    }
    
    @IBAction func dismissButtonPressed(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    
    
    
    func getVisitorParking(){
        mapViewParking.enabled = false
        if VisitorParkingList.isEmpty == true {
        UWSGFoodClientModel.sharedInstance().taskForGetMethod("parking/lots/visitor.json", parameters: [:]){(result, error) in
            
            if error == nil {
                performUIUpdatesOnMain(){
                    if let data = result["data"] as? [[String:AnyObject]] {
                            let visitorParking = data.map() {(dictionary: [String:AnyObject]) -> VisitorParking in
                                let visitorParking = VisitorParking(dictionary: dictionary, context: sharedContext)
                                return visitorParking
                        }
                        self.VisitorParkingList = visitorParking
                        for i in 0...visitorParking.count-1{
                            self.sectionName.append(visitorParking[i].lot_name)
                            self.sectionInfos.append([visitorParking[i].descriptions])
                            self.sectionNotes.append([visitorParking[i].note])
                        }
                        saveContext()
                                print(self.VisitorParkingList.count)
                        self.tableView.reloadData()
                        self.mapViewParking.enabled = true
                    }
                }
            }else {
                print("no data")
            }
        }
    }
    }

}
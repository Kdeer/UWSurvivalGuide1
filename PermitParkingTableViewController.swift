//
//  PermitParkingTableViewController.swift
//  UWSurvivalGuide
//
//  Created by Xiaochao Luo on 2016-07-10.
//  Copyright © 2016 Xiaochao Luo. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class PermitParkingTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var mapParkingButton: UIBarButtonItem!
    
    
    var permitParkingList = [PermitParking]()
    var sectionName: [String] = []
    var sectionInfos = [[String]]()
    var refreshControl: UIRefreshControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        refreshControl = UIRefreshControl()
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to Refresh")
        refreshControl.addTarget(self, action: #selector(PermitParkingTableViewController.refresh), forControlEvents: UIControlEvents.ValueChanged)
        tableView.addSubview(refreshControl)
        self.automaticallyAdjustsScrollViewInsets = false
        tableView.delegate = self
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 340
        
        fetchAndDeploy()
    }
    
    func refresh(){
        if permitParkingList.count > 0 {
            for i in 0...permitParkingList.count - 1 {
                sharedContext.deleteObject(permitParkingList[i])
                
            }
            sectionName.removeAll()
            sectionInfos.removeAll()
            saveContext()
            permitParkingList.removeAll()
        }
        tableView.reloadData()
        getPermitParking()
        refreshControl.endRefreshing()
    }
    
    func fetchAndDeploy(){
        permitParkingList = fetchAllPermits()
        
        if permitParkingList.count > 0 {
            for i in 0...self.permitParkingList.count-1 {
                self.sectionName.append("Lot" + " " + self.permitParkingList[i].lot_name)
                
                self.sectionInfos.append([self.permitParkingList[i].descriptions])
            }
            tableView.reloadData()
        }else {
            getPermitParking()
        }
    }
    
    
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return self.sectionName[section]
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return self.sectionName.count
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.sectionInfos[section].count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as! MeterParkingTableViewCell
        cell.parkingLotLabel.text = sectionInfos[indexPath.section][indexPath.row]
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let controller = self.storyboard!.instantiateViewControllerWithIdentifier("ParkingLocationViewController") as! ParkingLocationViewController
        controller.permitParking = self.permitParkingList[indexPath.section]
//        self.navigationController!.pushViewController(controller, animated: true)
        self.presentViewController(controller, animated: true, completion: nil)

    }
    
    @IBAction func MapVersionButton(sender: AnyObject) {
        let controller = self.storyboard!.instantiateViewControllerWithIdentifier("MapParkingLocationViewController") as! MapParkingLocationViewController
        controller.permitParkingList = self.permitParkingList
        controller.initParkingIndicator = "Permit"
        self.presentViewController(controller, animated: true, completion: nil)
        
    }
    
    @IBAction func dismissButtonPressed(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    func getPermitParking(){
        mapParkingButton.enabled = false
        if permitParkingList.isEmpty == true {
        UWSGFoodClientModel.sharedInstance().taskForGetMethod("parking/lots/permit.json", parameters: [:]){(result,error) in
            
            if error == nil{
                performUIUpdatesOnMain(){
                if let data = result["data"] as? [[String:AnyObject]]{
                    let permitParking = data.map() {(dictionary: [String:AnyObject]) -> PermitParking in
                        let permitParking = PermitParking(dictionary: dictionary, context: sharedContext)
                        return permitParking
                    }
                    self.permitParkingList = permitParking
                    for i in 0...permitParking.count-1 {
                        self.sectionName.append("Lot" + " " + permitParking[i].lot_name)
                        
                        self.sectionInfos.append([permitParking[i].descriptions])
                    }
                    print(self.sectionName)
                    saveContext()
                    self.tableView.reloadData()
                    self.mapParkingButton.enabled = true
                }
                }
            }
        }
        }
  
        
    }
}
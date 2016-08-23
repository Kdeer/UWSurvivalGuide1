//
//  MeterParkingTableViewController.swift
//  UWSurvivalGuide
//
//  Created by Xiaochao Luo on 2016-07-09.
//  Copyright © 2016 Xiaochao Luo. All rights reserved.
//

import Foundation
import UIKit
import CoreData


class MeterParkingTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!

    @IBOutlet weak var mapViewParking: UIBarButtonItem!
    
    var meterParkingList = [MeterParking]()
    var sectionTitle : [String] = []
    var descriptionInfos = [[String]]()
    var descriptionInfo: [String] = []
    var refreshControl: UIRefreshControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        refreshControl = UIRefreshControl()
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to Refresh")
        refreshControl.addTarget(self, action: #selector(MeterParkingTableViewController.refresh), forControlEvents: UIControlEvents.ValueChanged)
        tableView.addSubview(refreshControl)
        
        self.automaticallyAdjustsScrollViewInsets = false
        tableView.delegate = self
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 340
        fetchAndDeploy()
        
    }
    
    func refresh() {
        if meterParkingList.count > 0 {
            for i in 0...meterParkingList.count - 1 {
                sharedContext.deleteObject(meterParkingList[i])

            }
            saveContext()
            meterParkingList.removeAll()
        }
        sectionTitle.removeAll()
        getMeterParkingData()
        refreshControl.endRefreshing()
    }
    
    func fetchAndDeploy() {
        meterParkingList = fetchAllMeters()
        
        if meterParkingList.count > 0 {
            for i in 0...meterParkingList.count-1 {
            self.sectionTitle.append(self.meterParkingList[i].descriptions)
            }
            self.tableView.reloadData()
        }else {
            getMeterParkingData()
        }
    }
  
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sectionTitle.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("meterCell", forIndexPath: indexPath)  as! MeterParkingTableViewCell
        let meterRow = sectionTitle[indexPath.row]
        
        cell.descriptionLabel.text = meterRow
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {

        let controller = self.storyboard!.instantiateViewControllerWithIdentifier("ParkingLocationViewController") as! ParkingLocationViewController
        controller.meterParking = meterParkingList[indexPath.row]

        self.presentViewController(controller, animated: true, completion: nil)

    }
    
    @IBAction func MapVersionButton(sender: AnyObject) {
        let controller = self.storyboard!.instantiateViewControllerWithIdentifier("MapParkingLocationViewController") as! MapParkingLocationViewController
        controller.meterParkingList = self.meterParkingList
        controller.initParkingIndicator = "Meter"
        self.presentViewController(controller, animated: true, completion: nil)
        
    }
    
    @IBAction func dismissButtonPressed(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    
    func getMeterParkingData(){
        mapViewParking.enabled = false
        if meterParkingList.isEmpty == true {
        UWSGFoodClientModel.sharedInstance().taskForGetMethod("parking/lots/meter.json", parameters: [:]){(result,error) in
            
            if error == nil {
                performUIUpdatesOnMain(){
                if let data = result["data"] as? [[String:AnyObject]]{
                    let meterParking = data.map() {(dictionary: [String:AnyObject]) -> MeterParking in
                        let meterParking = MeterParking(dictionary: dictionary, context: sharedContext)
                        return meterParking
                    }
                    self.meterParkingList = meterParking
                    for i in 0...meterParking.count-1 {
                        self.sectionTitle.append(meterParking[i].descriptions)
                    }
                    saveContext()
                    self.tableView.reloadData()
                    self.mapViewParking.enabled = true
                }
            }
            }
        }
        }
        
    }
    
    

}
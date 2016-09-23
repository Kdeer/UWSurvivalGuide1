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
        refreshControl.addTarget(self, action: #selector(MeterParkingTableViewController.refresh), for: UIControlEvents.valueChanged)
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
                sharedContext.delete(meterParkingList[i])

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
  
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sectionTitle.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "meterCell", for: indexPath)  as! MeterParkingTableViewCell
        let meterRow = sectionTitle[(indexPath as NSIndexPath).row]
        
        cell.descriptionLabel.text = meterRow
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        let controller = self.storyboard!.instantiateViewController(withIdentifier: "ParkingLocationViewController") as! ParkingLocationViewController
        controller.meterParking = meterParkingList[(indexPath as NSIndexPath).row]

        self.present(controller, animated: true, completion: nil)

    }
    
    @IBAction func MapVersionButton(_ sender: AnyObject) {
        let controller = self.storyboard!.instantiateViewController(withIdentifier: "MapParkingLocationViewController") as! MapParkingLocationViewController
        controller.meterParkingList = self.meterParkingList
        controller.initParkingIndicator = "Meter"
        self.present(controller, animated: true, completion: nil)
        
    }
    
    @IBAction func dismissButtonPressed(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }

    
    func getMeterParkingData(){
        mapViewParking.isEnabled = false
        if meterParkingList.isEmpty == true {
        UWSGFoodClientModel.sharedInstance().taskForGetMethod("parking/lots/meter.json", parameters: [:]){(result,error) in
            
            if error == nil {
                performUIUpdatesOnMain(){
                if let data = result?["data"] as? [[String:AnyObject]]{
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
                    self.mapViewParking.isEnabled = true
                }
            }
            }
        }
        }
        
    }
    
    

}

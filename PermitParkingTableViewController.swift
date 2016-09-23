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
        refreshControl.addTarget(self, action: #selector(PermitParkingTableViewController.refresh), for: UIControlEvents.valueChanged)
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
                sharedContext.delete(permitParkingList[i])
                
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
    
    
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return self.sectionName[section]
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.sectionName.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.sectionInfos[section].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! MeterParkingTableViewCell
        cell.parkingLotLabel.text = sectionInfos[(indexPath as NSIndexPath).section][(indexPath as NSIndexPath).row]
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let controller = self.storyboard!.instantiateViewController(withIdentifier: "ParkingLocationViewController") as! ParkingLocationViewController
        controller.permitParking = self.permitParkingList[(indexPath as NSIndexPath).section]
//        self.navigationController!.pushViewController(controller, animated: true)
        self.present(controller, animated: true, completion: nil)

    }
    
    @IBAction func MapVersionButton(_ sender: AnyObject) {
        let controller = self.storyboard!.instantiateViewController(withIdentifier: "MapParkingLocationViewController") as! MapParkingLocationViewController
        controller.permitParkingList = self.permitParkingList
        controller.initParkingIndicator = "Permit"
        self.present(controller, animated: true, completion: nil)
        
    }
    
    @IBAction func dismissButtonPressed(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    func getPermitParking(){
        mapParkingButton.isEnabled = false
        if permitParkingList.isEmpty == true {
        UWSGFoodClientModel.sharedInstance().taskForGetMethod("parking/lots/permit.json", parameters: [:]){(result,error) in
            
            if error == nil{
                performUIUpdatesOnMain(){
                if let data = result?["data"] as? [[String:AnyObject]]{
                    let permitParking = data.map() {(dictionary: [String:AnyObject]) -> PermitParking in
                        PermitParking(dictionary: dictionary, context: sharedContext)
                    }
                    self.permitParkingList = permitParking
                    for i in 0...permitParking.count-1 {
                        self.sectionName.append("Lot" + " " + permitParking[i].lot_name)
                        
                        self.sectionInfos.append([permitParking[i].descriptions])
                    }
                    print(self.sectionName)
                    saveContext()
                    self.tableView.reloadData()
                    self.mapParkingButton.isEnabled = true
                }
                }
            }
        }
        }
  
        
    }
}

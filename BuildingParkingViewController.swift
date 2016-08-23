//
//  BuildingParkingViewController.swift
//  UWSurvivalGuide
//
//  Created by Xiaochao Luo on 2016-07-10.
//  Copyright © 2016 Xiaochao Luo. All rights reserved.
//

import Foundation
import UIKit
import CoreData


class BuildingParkingViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchResultsUpdating {
    

    
    @IBOutlet weak var tableView: UITableView!
    
    var buildingList = [BuildingList]()
    var resultSearchController: UISearchController!
    var filteredResults = [String]()
    var titleArray = [String]()
    var matchingItems = [BuildingList]()
    var refreshControl: UIRefreshControl!
    
    deinit{
        self.resultSearchController?.view.removeFromSuperview()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        refreshControl = UIRefreshControl()
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to Refresh")
        refreshControl.addTarget(self, action: #selector(VisitorParkingTableViewController.refresh), forControlEvents: UIControlEvents.ValueChanged)
        tableView.addSubview(refreshControl)
        
        self.definesPresentationContext = true
        self.automaticallyAdjustsScrollViewInsets = false
        self.tableView.delegate = self
        resultSearchController = UISearchController(searchResultsController: nil)
        resultSearchController.searchResultsUpdater = self
        resultSearchController.hidesNavigationBarDuringPresentation = false
        resultSearchController.dimsBackgroundDuringPresentation = false
        resultSearchController.searchBar.sizeToFit()
        
        tableView.tableHeaderView = resultSearchController.searchBar
        
        fetchAndLoad()
    }
    
    func refresh(){
        if buildingList.count > 0 {
            for i in 0...buildingList.count - 1 {
                sharedContext.deleteObject(buildingList[i])
                
            }
            saveContext()
            buildingList.removeAll()
        }
        tableView.reloadData()
        getBuilding()
        refreshControl.endRefreshing()
    }
    
    func fetchAndLoad(){
        buildingList = fetchAllPins()
        
        if buildingList.count > 0 {
            for i in 0...self.buildingList.count-1{
                self.titleArray.append(self.buildingList[i].building_name)
            }
            tableView.reloadData()
        }else {
            getBuilding()
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if resultSearchController.active {
            return filteredResults.count
        }else {
            return buildingList.count
        }
    }
    
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        filteredResults.removeAll(keepCapacity: false)
        let searchPredicate = NSPredicate(format: "SELF CONTAINS[c] %@", searchController.searchBar.text!)
        let array = (self.titleArray as NSArray).filteredArrayUsingPredicate(searchPredicate)
        filteredResults = array as! [String]
        
        tableView.reloadData()
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath)
        if resultSearchController.active {
            cell.textLabel!.text = self.filteredResults[indexPath.row]
            return cell
        }else {
        let buildingRow = buildingList[indexPath.row].building_name
        cell.textLabel?.text = buildingRow
        return cell
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let controller = self.storyboard!.instantiateViewControllerWithIdentifier("MapParkingLocationViewController") as! MapParkingLocationViewController
        let cell = tableView.cellForRowAtIndexPath(indexPath)
        print(cell?.textLabel?.text)
        print(buildingList.count)
        print(buildingList[10].building_name)
        for i in 0...buildingList.count-1{
            if cell?.textLabel?.text! == buildingList[i].building_name{
                print("Found it")

                controller.buildingPin = buildingList[i]
                controller.initParkingIndicator = "Monitor"
                controller.buildingInvolved = true
            }
        }

        self.presentViewController(controller, animated: true, completion: nil)
    }
    
    @IBAction func dismissButtonPressed(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    func getBuilding(){
        UWSGFoodClientModel.sharedInstance().taskForGetMethod("buildings/list.json", parameters: [:]){(result, error) in
            
            if error == nil{
                performUIUpdatesOnMain(){
                    if let data = result["data"] as? [[String:AnyObject]]{
                        let buildingList = data.map() {(dictionary: [String:AnyObject]) -> BuildingList in
                            let buildingList = BuildingList(dictionary: dictionary, context: self.sharedContext)
                            return buildingList
                        }
                        self.buildingList = buildingList
                        for i in 0...self.buildingList.count-1{
                            self.titleArray.append(self.buildingList[i].building_name)
                        }
                    }
                    self.tableView.reloadData()
                    print(self.buildingList.count)
                }
            }
        }
    }
    
    func fetchAllPins() -> [BuildingList] {
        
        // Create the Fetch Request
        let fetchRequest = NSFetchRequest(entityName: "BuildingList")
        
        // Execute the Fetch Request
        do {
            return try sharedContext.executeFetchRequest(fetchRequest) as! [BuildingList]
        } catch  let error as NSError {
            print("Error in fetchAllActors(): \(error)")
            return [BuildingList]()
        }
    }
    
    var sharedContext: NSManagedObjectContext {
        return CoreDataStackManager.sharedInstance().managedObjectContext
    }
    
    func saveContext() {
        CoreDataStackManager.sharedInstance().saveContext()
    }
}
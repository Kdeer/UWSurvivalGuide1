//
//  MenuTableViewController.swift
//  UWSurvivalGuide
//
//  Created by Xiaochao Luo on 2016-07-03.
//  Copyright © 2016 Xiaochao Luo. All rights reserved.
//

import Foundation
import UIKit


class MenuTableViewController: UIViewController, UITableViewDelegate,UITableViewDataSource {
    
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var mealLabel: UILabel!
    
    let section = ["pizza", "deep dish pizza", "calzone"]
    
    
    let items = [["Margarita", "BBQ Chicken", "Pepperoni"], ["sausage", "meat lovers", "veggie lovers"], ["sausage", "chicken pesto", "prawns", "mushrooms"]]
    
    var weekMenu: [[MealsDict]] = []
    var mealsInfo: [MealsDict] = []
    var outlet_ID: Int? = nil
    var whichMeal: String? = nil
    
    var theWeek = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"]
    var newWeek: [String] = []
    
    var theMeal: String? = nil

    override func viewDidLoad() {
        tableView.delegate = self
        mealLabel.text = whichMeal

    }
    
    @IBAction func weekButton(_ sender: AnyObject) {

    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        
        
        return newWeek[section]
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return self.newWeek.count
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        self.tableView.reloadData()
                if newWeek == [] {
                    self.mealLabel.text = "Sorry, This outlet's \(theMeal!) menu is not available"
                }

        self.automaticallyAdjustsScrollViewInsets = false
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return self.weekMenu[section].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "menuCell", for: indexPath) as UITableViewCell!
        
        let productName = self.weekMenu[(indexPath as NSIndexPath).section][(indexPath as NSIndexPath).row].product_name
        cell?.textLabel?.text = productName
        
        return cell!
    }
    
    func detectTheMeal(){
        if whichMeal?.range(of: "Lunch") != nil{
            whichMeal = "lunch"
        }else if whichMeal?.range(of: "Dinner") != nil {
            whichMeal = "dinner"
        }else if whichMeal?.range(of: "Breakfast") != nil {
            whichMeal = "breakfast"
        }
    }
    
    var weekTime: String? = nil
    
    func findTheMenu(){
        UWSGFoodClientModel.sharedInstance().taskForGetMethod("foodservices/menu.json", parameters: [:]){(result,error) in
            
            if error != nil {
                print(error)
            }else {
                performUIUpdatesOnMain(){
            //It starts with "data" first
                if let menuData = result?["data"] as? [String:AnyObject]{
                //under the "data", we have "outlets" and "date"
                    if let date = menuData["date"] as? [String:AnyObject]{
                        let startDate = date["start"] as? String
                        let endDate = date["end"] as? String
                        self.weekTime = startDate! + " To " + endDate!
                        self.mealLabel.text = self.weekTime
                        print (self.weekTime)
                    }
                    if let outlets = menuData["outlets"] as? [[String:AnyObject]]{
                //under "outlets", we match the id first, then go on "menu" if the outlet has the menu in api.
                        for i in 0...outlets.count-1{
                            if self.outlet_ID == outlets[i]["outlet_id"] as? Int {
                    //here comes the "menu"
                        let menu = outlets[i]["menu"] as? [[String:AnyObject]]
                                //under  menu we have 4 objects, we need to find the meals, that's why we use "for"
                        for d in 0...(menu?.count)! - 1 {
                            //d represents one day's meal
                            let meals = menu![d]["meals"] as? [String:AnyObject]
                            //after find the meals, we need to find which meal menu we want.
                            if let meal = meals![self.whichMeal!] as? [[String:AnyObject]]{
                            
                                //append the meal information for
                            for item in meal {
                                self.mealsInfo.append(MealsDict(dictionary: item))
                            }
                                //then append the meal to the weekMenu
                            self.weekMenu.append(self.mealsInfo)
                            self.mealsInfo.removeAll()
                            }else {
                                print("menu is not available")
                            }
                                }
                        print(self.weekMenu)
                    }
                }
                        if self.weekMenu.count > 0 {
                    for i in 0...self.weekMenu.count - 1{
                        if self.weekMenu[i].isEmpty != true {
                        self.newWeek.append(self.theWeek[i])
                        }
                    }
                    print(self.newWeek)
                    self.tableView.reloadData()
                        }
                    }
                    }
                }
        }
    }
    }
    
    
    
    
    
    
    
    
    
    
    
    
}

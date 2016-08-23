//
//  EXFoodOutletTableViewController.swift
//  UWSurvivalGuide
//
//  Created by Xiaochao Luo on 2016-07-07.
//  Copyright © 2016 Xiaochao Luo. All rights reserved.
//

import Foundation

extension FoodOutletTableViewController {
    
    func detectTheMeal(){
        if whichMeal?.rangeOfString("Lunch") != nil{
            whichMeal = "lunch"
        }else if whichMeal?.rangeOfString("Dinner") != nil {
            whichMeal = "dinner"
        }else if whichMeal?.rangeOfString("Breakfast") != nil {
            whichMeal = "breakfast"
        }
    }
    
    func findTheMenu(){
        UWSGFoodClientModel.sharedInstance().taskForGetMethod("foodservices/menu.json", parameters: [:]){(result,error) in
            
            if error != nil {
                print(error)
            }else {
                performUIUpdatesOnMain(){
                    //It starts with "data" first
                    if let menuData = result["data"] as? [String:AnyObject]{
                        //under the "data", we have "outlets" and "date"
                        if let date = menuData["date"] as? [String:AnyObject]{
                            let startDate = date["start"] as? String
                            let endDate = date["end"] as? String
                            self.weekTime = startDate! + " To " + endDate!
//                            self.mealLabel.text = self.weekTime
                        }
                        if let outlets = menuData["outlets"] as? [[String:AnyObject]]{
                            //under "outlets", we match the id first, then go on "menu" if the outlet has the menu in api.
                            print(outlets.count)
                            print(self.locationInfo1.outlet_id)
                            for i in 0...outlets.count-1{
                                if self.locationInfo1.outlet_id == outlets[i]["outlet_id"] as? Int {
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
                                print(self.whichMeal)
                                print(self.newWeek)
                                if self.whichMeal == "lunch"  {
                                    self.whichMeal = "Lunch"
                                }
                                let controller = self.storyboard!.instantiateViewControllerWithIdentifier("MenuTableViewController") as! MenuTableViewController
                                controller.outlet_ID = self.foodInfo.outlet_id
                                controller.whichMeal = self.weekTime
                                controller.newWeek = self.newWeek
                                controller.theWeek = self.theWeek
                                controller.weekMenu = self.weekMenu
                                controller.theMeal = self.whichMeal
                                self.navigationController!.pushViewController(controller, animated: true)
                            }else {
                                print("menu is not available")
                            }


                        }
                        
                    }
                }
            }
        }
    }
    
    
}
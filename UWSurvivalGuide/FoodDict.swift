//
//  FoodDict.swift
//  UWSurvivalGuide
//
//  Created by Xiaochao Luo on 2016-07-02.
//  Copyright © 2016 Xiaochao Luo. All rights reserved.
//

import Foundation

enum MealType {
    case Breakfast, Lunch, Dinner
}

struct theMeal {
    var mealType: MealType
    
    init(mealType: MealType!){
        self.mealType = mealType
    }
}

struct FoodDict {
    
    var outlet_name: String
    var outlet_id: Int
    var has_breakfast: Int
    var has_lunch: Int
    var has_dinner: Int
    
    init(dictionary: [String:AnyObject]){
        
        outlet_name = dictionary["outlet_name"] as! String
        outlet_id = dictionary["outlet_id"] as! Int
        has_breakfast = dictionary["has_breakfast"] as! Int
        has_lunch = dictionary["has_lunch"] as! Int
        has_dinner = dictionary["has_dinner"] as! Int
    }
    
    
    
    
    
    
    
}
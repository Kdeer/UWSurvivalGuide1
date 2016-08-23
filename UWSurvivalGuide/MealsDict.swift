//
//  MealsDict.swift
//  UWSurvivalGuide
//
//  Created by Xiaochao Luo on 2016-07-03.
//  Copyright © 2016 Xiaochao Luo. All rights reserved.
//

import Foundation


struct  MealsDict {
    var diet_type: String!
    var product_id: Int!
    var product_name: String!
    
    init(dictionary: [String : AnyObject]){
        
        diet_type = dictionary["diet_type"] as? String
        product_id = dictionary["product_id"] as? Int
        product_name = dictionary["product_name"] as? String
        
    }
}
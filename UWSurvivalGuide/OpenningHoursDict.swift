//
//  OpenningHoursDict.swift
//  UWSurvivalGuide
//
//  Created by Xiaochao Luo on 2016-07-06.
//  Copyright © 2016 Xiaochao Luo. All rights reserved.
//

import Foundation


struct OpeningHours{
    
    var opening_hour: String!
    var closing_hour: String!
    var is_closed: Int
    
    
    init(dictionary: [String:AnyObject]){
        
        opening_hour = dictionary["openning_hour"] as? String
        closing_hour = dictionary["closing_hour"] as? String
        is_closed = dictionary["is_closed"] as! Int
        
    }
    
    
}
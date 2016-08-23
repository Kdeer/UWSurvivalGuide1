//
//  LocationDict.swift
//  UWSurvivalGuide
//
//  Created by Xiaochao Luo on 2016-07-04.
//  Copyright © 2016 Xiaochao Luo. All rights reserved.
//

import Foundation
import UIKit

//Even thoguh it is only location, but it contains the most completed information, funny huh?


struct LocationDict {
    var outlet_id: Int
    var outlet_name: String
    var building: String
    var logo: String!
    var latitude: Double
    var longitude: Double
    var description: String!
    var notice: String!
    var is_open_now: Int
    var opening_hours: [String:AnyObject]
    
    init(dictionary:[String : AnyObject]){
        
        outlet_id = dictionary["outlet_id"] as! Int
        outlet_name = dictionary["outlet_name"] as! String
        building = dictionary["building"] as! String
        logo = dictionary["logo"] as? String
        latitude = dictionary["latitude"] as! Double
        longitude = dictionary["longitude"] as! Double
        description = dictionary["description"] as? String
        notice = dictionary["notice"] as? String
        is_open_now = dictionary["is_open_now"] as! Int
        opening_hours = dictionary["opening_hours"] as! [String:AnyObject]
        
    }
}
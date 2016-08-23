//
//  MeterParkingDict.swift
//  UWSurvivalGuide
//
//  Created by Xiaochao Luo on 2016-07-08.
//  Copyright © 2016 Xiaochao Luo. All rights reserved.
//

import Foundation



struct MonitorParking {
    
    var lot_name: String
    var latitude: Double
    var longitude: Double
    var capacity: Int
    var current_count: Int
    var percent_filled: Int
    var last_update: String
    
    
    init(dictionary: [String: AnyObject]){
        lot_name = dictionary["lot_name"] as! String
        latitude = dictionary["latitude"] as! Double
        longitude = dictionary["longitude"] as! Double
        capacity = dictionary["capacity"] as! Int
        current_count = dictionary["current_count"] as! Int
        percent_filled = dictionary["percent_filled"] as! Int
        last_update = dictionary["last_updated"] as! String
        
    }
    
    
    
    
    
    
    
    
    
    
    
    
}
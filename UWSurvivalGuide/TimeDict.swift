//
//  TimeDict.swift
//  UWSurvivalGuide
//
//  Created by Xiaochao Luo on 2016-07-28.
//  Copyright © 2016 Xiaochao Luo. All rights reserved.
//

import Foundation
import UIKit

class Time: NSObject, NSCoding {
    
    var year: Int?
    var month: Int?
    var day: Int?
    var hour: Int?
    
    
    init(dictionary: [String:AnyObject]) {
        year = dictionary["year"] as? Int
        month = dictionary["month"] as? Int
        day = dictionary["day"] as? Int
        hour = dictionary["hour"] as? Int
    }
    
    func encodeWithCoder(archiver: NSCoder) {
        archiver.encodeObject(year, forKey: "year")
        archiver.encodeObject(month, forKey: "month")
        archiver.encodeObject(day, forKey: "day")
        archiver.encodeObject(hour, forKey: "hour")
    }
    
    required init(coder unarchiver: NSCoder) {
        super.init()
        year = unarchiver.decodeObjectForKey("year") as? Int
        month = unarchiver.decodeObjectForKey("month") as? Int
        day = unarchiver.decodeObjectForKey("day") as? Int
        hour = unarchiver.decodeObjectForKey("hour") as? Int
    }
    
    
    
    
    
    
    
    
    
    
}
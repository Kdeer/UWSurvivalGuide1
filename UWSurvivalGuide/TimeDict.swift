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
    
    func encode(with archiver: NSCoder) {
        archiver.encode(year, forKey: "year")
        archiver.encode(month, forKey: "month")
        archiver.encode(day, forKey: "day")
        archiver.encode(hour, forKey: "hour")
    }
    
    required init(coder unarchiver: NSCoder) {
        super.init()
        year = unarchiver.decodeObject(forKey: "year") as? Int
        month = unarchiver.decodeObject(forKey: "month") as? Int
        day = unarchiver.decodeObject(forKey: "day") as? Int
        hour = unarchiver.decodeObject(forKey: "hour") as? Int
    }
    
    
    
    
    
    
    
    
    
    
}

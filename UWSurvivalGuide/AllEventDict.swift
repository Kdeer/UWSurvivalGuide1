//
//  AllEventDict.swift
//  UWSurvivalGuide
//
//  Created by Xiaochao Luo on 2016-07-16.
//  Copyright © 2016 Xiaochao Luo. All rights reserved.
//

import Foundation


struct AllEvent {
    var id: Int!
    var site: String!
    var site_name: String!
    var times : [[String:String]]!
    var title: String!
    var type: [String]!
    var link: String!
    var updated: String!
    
    init(dictionary:[String:AnyObject]){
        
        id = dictionary["id"] as? Int
        site = dictionary["site"] as? String
        site_name = dictionary["site_name"] as? String
        title = dictionary["title"] as? String
        times = dictionary["times"] as? [[String:String]]
        type = dictionary["type"] as? [String]
        link = dictionary["link"] as? String
        updated = dictionary["updated"] as? String
    }
}

struct TimeDict {
    var startTime: String!
    var endTime: String!
    
    init(dictionary:[String:AnyObject]){
        startTime = dictionary["start"] as? String
        endTime = dictionary["end"] as? String
    }
}
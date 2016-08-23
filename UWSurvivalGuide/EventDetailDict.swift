//
//  EventDetailDict.swift
//  UWSurvivalGuide
//
//  Created by Xiaochao Luo on 2016-07-16.
//  Copyright © 2016 Xiaochao Luo. All rights reserved.
//

import Foundation


struct EventDetail {
    var cost: String!
    var descriptions: String!
    var id: Int!
    var link: String!
    var site: String!
    var title: String!
    var type: String!
    var site_name: String!
    
    init(dictionary: [String:AnyObject]){

        site = dictionary["site"] as? String
        cost = dictionary["cost"] as? String
        descriptions = dictionary["description"] as? String
        id = dictionary["id"] as? Int
        link = dictionary["link"] as? String
        title = dictionary["title"] as? String
        type = dictionary["type"] as? String
        site_name = dictionary["site_name"] as? String
    }
    
}


struct EventTime{
    var start_day: String!
    var start_date: String!
    var start_time: String!
    
    init(dictionary: [String:AnyObject]){
        start_day = dictionary["start_day"] as? String
        start_date = dictionary["start_date"] as? String
        start_time = dictionary["start_time"] as? String
    }
}


struct EventLocation {
    var city: String!
    var street: String!
    var postal_code: String!
    var country: String!
    var longitude: Double!
    var latitude: Double!
    var additional: String!
    var province: String!
    var name: String!
    
    init(dictionary: [String:AnyObject]){
        city = dictionary["city"] as? String
        street = dictionary["street"] as? String
        postal_code = dictionary["postal_code"] as? String
        country = dictionary["country"] as? String
        longitude = dictionary["longitude"] as? Double
        latitude = dictionary["latitude"] as? Double
        additional = dictionary["additional"] as? String
        province = dictionary["province"] as? String
        name = dictionary["name"] as? String
    }

}


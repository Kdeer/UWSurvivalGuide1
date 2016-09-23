//
//  FavoriateEventDict.swift
//  UWSurvivalGuide
//
//  Created by Xiaochao Luo on 2016-07-19.
//  Copyright © 2016 Xiaochao Luo. All rights reserved.
//

import Foundation
import CoreData

class ExpectedEvent: NSManagedObject {
    
    @NSManaged var id: NSNumber!
    @NSManaged var site: String!
    @NSManaged var site_name: String!
    @NSManaged var link: String!
    @NSManaged var times: String!
    @NSManaged var title: String!
    @NSManaged var type: String!
    @NSManaged var isExpired: NSNumber!

    
    override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
    }
    
    init(dictionary: [String:AnyObject], context: NSManagedObjectContext){
        
        let entity =  NSEntityDescription.entity(forEntityName: "ExpectedEvent", in: context)!
        super.init(entity: entity, insertInto: context)
        
        id = dictionary["id"] as? Int as NSNumber!
        site = dictionary["site"] as? String
        site_name = dictionary["site_name"] as? String
        link = dictionary["link"] as? String
        times = dictionary["times"] as? String
        title = dictionary["title"] as? String
        type = dictionary["type"] as? String
        isExpired = dictionary["isExpired"] as? Bool as NSNumber!

    }
 
    
}

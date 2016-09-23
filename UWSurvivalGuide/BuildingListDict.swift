//
//  BuildingListDict.swift
//  UWSurvivalGuide
//
//  Created by Xiaochao Luo on 2016-07-10.
//  Copyright © 2016 Xiaochao Luo. All rights reserved.
//

import Foundation
import CoreData

class BuildingList: NSManagedObject {
    @NSManaged var building_id: String!
    @NSManaged var building_code: String!
    @NSManaged var building_name: String!
    @NSManaged var latitude: NSNumber!
    @NSManaged var longitude: NSNumber!
    
    override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
    }
    
    init(dictionary: [String:AnyObject], context: NSManagedObjectContext){
        
        let entity =  NSEntityDescription.entity(forEntityName: "BuildingList", in: context)!
        
        super.init(entity: entity, insertInto: context)
        building_id = dictionary["building_id"] as? String
        building_code = dictionary["building_code"] as? String
        building_name = dictionary["building_name"] as? String
        latitude = dictionary["latitude"] as? Double as NSNumber!
        longitude = dictionary["longitude"] as? Double as NSNumber!
    }
}

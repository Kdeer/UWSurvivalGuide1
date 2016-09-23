//
//  MeterParkingDict.swift
//  UWSurvivalGuide
//
//  Created by Xiaochao Luo on 2016-07-09.
//  Copyright © 2016 Xiaochao Luo. All rights reserved.
//

import Foundation
import CoreData


class MeterParking: NSManagedObject {
    @NSManaged var lot_name: String!
    @NSManaged var descriptions: String!
    @NSManaged var note: String!
    @NSManaged var latitude: NSNumber
    @NSManaged var longitude: NSNumber
    
    override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
    }
    
    init(dictionary: [String:AnyObject], context: NSManagedObjectContext){
        
        let entity =  NSEntityDescription.entity(forEntityName: "MeterParking", in: context)!
        super.init(entity: entity, insertInto: context)
        
        lot_name = dictionary["lot_name"] as? String
        descriptions = dictionary["description"] as? String
        note = dictionary["note"] as? String
        latitude = dictionary["latitude"] as! NSNumber
        longitude = dictionary["longitude"] as! NSNumber
    }
    
    
    
    
}

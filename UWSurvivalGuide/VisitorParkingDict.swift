//
//  VisitorParkingDict.swift
//  UWSurvivalGuide
//
//  Created by Xiaochao Luo on 2016-07-10.
//  Copyright © 2016 Xiaochao Luo. All rights reserved.
//

import Foundation
import CoreData

class VisitorParking: NSManagedObject {
    
   @NSManaged var lot_name: String!
   @NSManaged var descriptions: String!
   @NSManaged var note: String!
   @NSManaged var latitude: NSNumber
   @NSManaged var longitude: NSNumber
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    init(dictionary: [String:AnyObject], context: NSManagedObjectContext){
        
        let entity =  NSEntityDescription.entityForName("VisitorParking", inManagedObjectContext: context)!
        
        super.init(entity: entity, insertIntoManagedObjectContext: context)
        lot_name = dictionary["name"] as? String
        descriptions = dictionary["description"] as? String
        note = dictionary["note"] as? String
        latitude = dictionary["latitude"] as! Double
        longitude = dictionary["longitude"] as! Double
    }
}
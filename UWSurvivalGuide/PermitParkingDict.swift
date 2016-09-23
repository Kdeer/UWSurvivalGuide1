//
//  PermitParkingDict.swift
//  UWSurvivalGuide
//
//  Created by Xiaochao Luo on 2016-07-10.
//  Copyright © 2016 Xiaochao Luo. All rights reserved.
//

import Foundation
import CoreData

class PermitParking: NSManagedObject {
    @NSManaged var lot_name: String!
    @NSManaged var descriptions: String!
    @NSManaged var latitude: NSNumber
    @NSManaged var longitude: NSNumber
    
    override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
    }
    
    init(dictionary: [String:AnyObject], context: NSManagedObjectContext){
    
        let entity =  NSEntityDescription.entity(forEntityName: "PermitParking", in: context)!
        super.init(entity: entity, insertInto: context)
        lot_name = dictionary["name"] as? String
        descriptions = dictionary["description"] as? String
        latitude = dictionary["latitude"] as! NSNumber
        longitude = dictionary["longitude"] as! NSNumber
    }
 
}

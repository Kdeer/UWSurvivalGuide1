//
//  NewsDict.swift
//  UWSurvivalGuide
//
//  Created by Xiaochao Luo on 2016-07-24.
//  Copyright © 2016 Xiaochao Luo. All rights reserved.
//

import Foundation
import CoreData
import UIKit

class News: NSManagedObject {
    @NSManaged var id: NSNumber!
    @NSManaged var link: String!
    @NSManaged var published: String!
    @NSManaged var site: String!
    @NSManaged var title: String!
    @NSManaged var updatedAt: String!
    @NSManaged var imageURL: String!
    @NSManaged var descriptions: String!
    @NSManaged var descriptions_raw: String!
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    init(dictionary: [String:AnyObject], context: NSManagedObjectContext){
        
        let entity =  NSEntityDescription.entityForName("News", inManagedObjectContext: context)!
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    
        id = dictionary["id"] as? Int
        link = dictionary["link"] as? String
        published = dictionary["published"] as? String
        site = dictionary["site"] as? String
        title = dictionary["title"] as? String
        updatedAt = dictionary["updated"] as? String
        imageURL = dictionary["imageURL"] as? String
        descriptions = dictionary["descriptions"] as? String
        descriptions_raw = dictionary["descriptions_raw"] as? String
    }
    
    var newsImage: UIImage? {
        get {
            return UWSGFoodClientModel.Caches.imageCache.imageWithIdentifier(String(id))
        }
        set {
            UWSGFoodClientModel.Caches.imageCache.storeImage(newValue, withIdentifier: String(id))
        }
    }
}
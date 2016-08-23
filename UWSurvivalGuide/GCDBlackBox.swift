//
//  GCDBlackBox.swift
//  FlickFinder
//
//  Created by Jarrod Parkes on 11/5/15.
//  Copyright © 2015 Udacity. All rights reserved.
//

import Foundation
import CoreData
import UIKit


func performUIUpdatesOnMain(updates: () -> Void) {
    dispatch_async(dispatch_get_main_queue()) {
        updates()
    }
}


func fetchAllMeters() -> [MeterParking] {
    
    // Create the Fetch Request
    let fetchRequest = NSFetchRequest(entityName: "MeterParking")
    
    // Execute the Fetch Request
    do {
        return try sharedContext.executeFetchRequest(fetchRequest) as! [MeterParking]
    } catch  let error as NSError {
        print("Error in fetchAllActors(): \(error)")
        return [MeterParking]()
    }
}

func fetchAllPermits() -> [PermitParking] {
    
    // Create the Fetch Request
    let fetchRequest = NSFetchRequest(entityName: "PermitParking")
    
    // Execute the Fetch Request
    do {
        return try sharedContext.executeFetchRequest(fetchRequest) as! [PermitParking]
    } catch  let error as NSError {
        print("Error in fetchAllActors(): \(error)")
        return [PermitParking]()
    }
}

var sharedContext: NSManagedObjectContext {
    return CoreDataStackManager.sharedInstance().managedObjectContext
}

func saveContext() {
    CoreDataStackManager.sharedInstance().saveContext()
}

func fetchAllVisitors() -> [VisitorParking] {
    
    // Create the Fetch Request
    let fetchRequest = NSFetchRequest(entityName: "VisitorParking")
    
    // Execute the Fetch Request
    do {
        return try sharedContext.executeFetchRequest(fetchRequest) as! [VisitorParking]
    } catch  let error as NSError {
        print("Error in fetchAllActors(): \(error)")
        return [VisitorParking]()
    }
}

func fetchExpectedEvents() -> [ExpectedEvent] {
    
    // Create the Fetch Request
    let fetchRequest = NSFetchRequest(entityName: "ExpectedEvent")
    
    // Execute the Fetch Request
    do {
        return try sharedContext.executeFetchRequest(fetchRequest) as! [ExpectedEvent]
    } catch  let error as NSError {
        print("Error in fetchAllActors(): \(error)")
        return [ExpectedEvent]()
    }
}

func fetchAllNews() -> [News] {
    
    // Create the Fetch Request
    let fetchRequest = NSFetchRequest(entityName: "News")
    
    // Execute the Fetch Request
    do {
        return try sharedContext.executeFetchRequest(fetchRequest) as! [News]
    } catch  let error as NSError {
        print("Error in fetchAllActors(): \(error)")
        return [News]()
    }
}







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


func performUIUpdatesOnMain(_ updates: @escaping () -> Void) {
    DispatchQueue.main.async {
        updates()
    }
}


func fetchAllMeters() -> [MeterParking] {
    
    // Create the Fetch Request
//    let fetchRequest = NSFetchRequest(entityName: "MeterParking")
    let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "MeterParking")
    // Execute the Fetch Request
    do {
        return try sharedContext.fetch(fetchRequest) as! [MeterParking]
    } catch  let error as NSError {
        print("Error in fetchAllActors(): \(error)")
        return [MeterParking]()
    }
}

func fetchAllPermits() -> [PermitParking] {
    
    // Create the Fetch Request
//    let fetchRequest = NSFetchRequest(entityName: "PermitParking")
    let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "PermitParking")
    // Execute the Fetch Request
    do {
        return try sharedContext.fetch(fetchRequest) as! [PermitParking]
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
//    let fetchRequest = NSFetchRequest(entityName: "VisitorParking")
    let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "VisitorParking")
    // Execute the Fetch Request
    do {
        return try sharedContext.fetch(fetchRequest) as! [VisitorParking]
    } catch  let error as NSError {
        print("Error in fetchAllActors(): \(error)")
        return [VisitorParking]()
    }
}

func fetchExpectedEvents() -> [ExpectedEvent] {
    
    // Create the Fetch Request
//    let fetchRequest = NSFetchRequest(entityName: "ExpectedEvent")
    let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "ExpectedEvent")
    // Execute the Fetch Request
    do {
        return try sharedContext.fetch(fetchRequest) as! [ExpectedEvent]
    } catch  let error as NSError {
        print("Error in fetchAllActors(): \(error)")
        return [ExpectedEvent]()
    }
}

func fetchAllNews() -> [News] {
    
    // Create the Fetch Request
//    let fetchRequest = NSFetchRequest(entityName: "News")
    let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "News")
    // Execute the Fetch Request
    do {
        return try sharedContext.fetch(fetchRequest) as! [News]
    } catch  let error as NSError {
        print("Error in fetchAllActors(): \(error)")
        return [News]()
    }
}







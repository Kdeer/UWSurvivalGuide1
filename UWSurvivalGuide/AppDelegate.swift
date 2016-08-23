//
//  AppDelegate.swift
//  UWSurvivalGuide
//
//  Created by Xiaochao Luo on 2016-07-01.
//  Copyright © 2016 Xiaochao Luo. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    var quitTime: Time!

    var launchingTime = String()
    var refresh = true
    var myViewController: NewsViewController?


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        // Override point for customization after application launch.
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        self.quitTime = Time(dictionary: ["year": quitingTime()[0], "month": quitingTime()[1], "day": quitingTime()[2], "hour": quitingTime()[3]])
        
        NSKeyedArchiver.archiveRootObject(self.quitTime, toFile: self.filePath)
    }

    func applicationDidEnterBackground(application: UIApplication) {

        self.quitTime = Time(dictionary: ["year": quitingTime()[0], "month": quitingTime()[1], "day": quitingTime()[2], "hour": quitingTime()[3]])

        NSKeyedArchiver.archiveRootObject(self.quitTime, toFile: self.filePath)
        self.refresh = false

    }
    
    func quitingTime() -> [Int]{
        var theTime = [Int]()
        let date = NSDate()
        let calendar = NSCalendar.currentCalendar()
        let components = calendar.components([.Day, .Month, .Year, .Hour], fromDate: date)
        
        let hour = components.hour
        let day = components.day
        let month = components.month
        let year = components.year
        print(hour)
        
        theTime = [year, month, day, hour]
        
        return theTime
    }
    
    func whetherToRefresh(time: Time) -> Bool {
        
        let date = NSDate()
        let calendar = NSCalendar.currentCalendar()
        let components = calendar.components([.Day, .Month, .Year, .Hour], fromDate: date)
        
        let hour = components.hour
        let day = components.day
        let month = components.month
        let year = components.year
        
        if year > time.year {
            refresh = true
            return refresh
        }else if year == time.year && month > time.month {
            refresh = true
            return refresh
        }else if year == time.year && month == time.month && day > time.day {
            refresh = true
            return refresh
        }else if year == time.year! && month == time.month && day == time.day && hour >= time.hour! + 3  {
            print("it's time")
            refresh = true
            return refresh
        }else {
            print("not yet to refresh")
            refresh = false
            return refresh
        }
        
    }

    func applicationWillEnterForeground(application: UIApplication) {

    }

    func applicationDidBecomeActive(application: UIApplication) {
        
        if let theTimeToQuit = NSKeyedUnarchiver.unarchiveObjectWithFile(filePath) as? Time{
            self.quitTime = theTimeToQuit
            if self.quitTime != nil {
                whetherToRefresh(self.quitTime)
            }
            if whetherToRefresh(self.quitTime) == true {
                print(self.quitTime.hour)
                print("reloading")
                myViewController?.viewDidLoad()
            }
        }


        
        
        
    }

    func applicationWillTerminate(application: UIApplication) {
        self.quitTime = Time(dictionary: ["year": quitingTime()[0], "month": quitingTime()[1], "day": quitingTime()[2], "hour": quitingTime()[3]])
        
        NSKeyedArchiver.archiveRootObject(self.quitTime, toFile: self.filePath)
    }

    
    var filePath : String {
        let manager = NSFileManager.defaultManager()
        let url = manager.URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first!
        return url.URLByAppendingPathComponent("timeArray").path!
    }

}


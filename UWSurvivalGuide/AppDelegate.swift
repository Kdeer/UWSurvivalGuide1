//
//  AppDelegate.swift
//  UWSurvivalGuide
//
//  Created by Xiaochao Luo on 2016-07-01.
//  Copyright © 2016 Xiaochao Luo. All rights reserved.
//

import UIKit
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    var quitTime: Time!

    var launchingTime = String()
    var refresh = false
    var myViewController: NewsViewController?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        // Override point for customization after application launch.
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        self.quitTime = Time(dictionary: ["year": quitingTime()[0] as AnyObject, "month": quitingTime()[1] as AnyObject, "day": quitingTime()[2] as AnyObject, "hour": quitingTime()[3] as AnyObject])
        
        NSKeyedArchiver.archiveRootObject(self.quitTime, toFile: self.filePath)
    }

    func applicationDidEnterBackground(_ application: UIApplication) {

        self.quitTime = Time(dictionary: ["year": quitingTime()[0] as AnyObject, "month": quitingTime()[1] as AnyObject, "day": quitingTime()[2] as AnyObject, "hour": quitingTime()[3] as AnyObject])

        NSKeyedArchiver.archiveRootObject(self.quitTime, toFile: self.filePath)
        self.refresh = false

    }
    
    func quitingTime() -> [Int]{
        var theTime = [Int]()
        let date = Date()
        let calendar = Calendar.current
        let components = (calendar as NSCalendar).components([.day, .month, .year, .hour], from: date)
        
        let hour = components.hour
        let day = components.day
        let month = components.month
        let year = components.year
        print(hour)
        
        theTime = [year!, month!, day!, hour!]
        
        return theTime
    }
    
    @discardableResult func whetherToRefresh(_ time: Time) -> Bool {
        
        let date = Date()
        let calendar = Calendar.current
        let components = (calendar as NSCalendar).components([.day, .month, .year, .hour], from: date)
        
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
        }else if year! == time.year! && month! == time.month! && day! == time.day! && hour! >= time.hour! + 3  {
            print("it's time")
            refresh = true
            return refresh
        }else {
            print("not yet to refresh")
            refresh = false
            return refresh
        }
        
    }

    func applicationWillEnterForeground(_ application: UIApplication) {

    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        
        if let theTimeToQuit = NSKeyedUnarchiver.unarchiveObject(withFile: filePath) as? Time{
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

    func applicationWillTerminate(_ application: UIApplication) {
        self.quitTime = Time(dictionary: ["year": quitingTime()[0] as AnyObject, "month": quitingTime()[1] as AnyObject, "day": quitingTime()[2] as AnyObject, "hour": quitingTime()[3] as AnyObject])
        
        NSKeyedArchiver.archiveRootObject(self.quitTime, toFile: self.filePath)
    }

    
    var filePath : String {
        let manager = FileManager.default
        let url = manager.urls(for: .documentDirectory, in: .userDomainMask).first!
        return url.appendingPathComponent("timeArray").path
    }

}


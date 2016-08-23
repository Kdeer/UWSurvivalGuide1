//
//  MapParkingLocationViewController.swift
//  UWSurvivalGuide
//
//  Created by Xiaochao Luo on 2016-07-10.
//  Copyright © 2016 Xiaochao Luo. All rights reserved.
//

import Foundation
import UIKit
import MapKit
import CoreData


class MapParkingLocationViewController: UIViewController, MKMapViewDelegate {
    
    
    
    @IBOutlet weak var mapView: MKMapView!
    
    @IBOutlet weak var segmentControl: UISegmentedControl!
    
    var monitorParkingList = [MonitorParking]()
    var visitorParkingList = [VisitorParking]()
    var permitParkingList = [PermitParking]()
    var meterParkingList = [MeterParking]()
    var mapAnnotations = [MKAnnotation]()
    var placemark: MKPlacemark!
    var initParkingIndicator: String? = nil
    var buildingPin: BuildingList!
    var buildingInvolved: Bool? = false
    var center : CLLocationCoordinate2D! = nil

    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        mapView.mapType = .Hybrid
        initParkingType()
        loadOneParkingList()

    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        print(monitorParkingList.count, visitorParkingList.count, permitParkingList.count, meterParkingList.count, mapAnnotations.count)
    }
    
    func initParkingType(){
        if initParkingIndicator == "Monitor"{
            segmentControl.selectedSegmentIndex = 0
        }else if initParkingIndicator == "Visitor"{
            segmentControl.selectedSegmentIndex = 1
        }else if initParkingIndicator == "Permit" {
            segmentControl.selectedSegmentIndex = 2
        }else if initParkingIndicator == "Meter"{
            segmentControl.selectedSegmentIndex = 3
        }
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    @IBAction func segmentSelected(sender: AnyObject) {
        
        switch segmentControl.selectedSegmentIndex {
        case 0:
            getMonitorParkingData()
        case 1:
            initParkingIndicator = "Visitor"
            getVisitorParkingData()
        case 2:
            initParkingIndicator = "Permit"
            getPermitParkingData()
        case 3:
            initParkingIndicator = "Meter"
            getMeterParkingData()
        default:
            break
        }
    }
    
    func getMonitorParkingData(){
        
        UWSGFoodClientModel.sharedInstance().taskForGetMethod("parking/watpark.json", parameters: [:]){(result, error) in
            
            if error == nil {
                performUIUpdatesOnMain(){
                    if let meterParkingResult = result["data"] as? [[String:AnyObject]] {
                        for item in meterParkingResult{
                            self.monitorParkingList.append(MonitorParking(dictionary: item))
                        }
                    }
                    self.loadMonitorLocation()
                }
            }
        }
    }
    
    func getVisitorParkingData(){
        
        self.visitorParkingList = fetchAllVisitors()
        
        if visitorParkingList.isEmpty == true {
        UWSGFoodClientModel.sharedInstance().taskForGetMethod("parking/lots/visitor.json", parameters: [:]){(result, error) in
            
            if error == nil {
                performUIUpdatesOnMain(){
                    if let data = result["data"] as? [[String:AnyObject]] {
                        let visitorParking = data.map() {(dictionary: [String:AnyObject]) -> VisitorParking in
                            let visitorParking = VisitorParking(dictionary: dictionary, context: sharedContext)
                            return visitorParking
                            
                    }
                    self.visitorParkingList = visitorParking
                    }
                    saveContext()
                    self.loadVisitorLocation()
                }
            }
            }
        }else{
            self.loadVisitorLocation()
        }
    }
    
    func getPermitParkingData(){
        
        self.permitParkingList = fetchAllPermits()
        
        if permitParkingList.isEmpty == true {
        
        UWSGFoodClientModel.sharedInstance().taskForGetMethod("parking/lots/permit.json", parameters: [:]){(result,error) in
            
            if error == nil{
                performUIUpdatesOnMain(){
                    if let data = result["data"] as? [[String:AnyObject]]{
                        let permitParking = data.map() {(dictionary: [String:AnyObject]) -> PermitParking in
                            let permitParking = PermitParking(dictionary: dictionary, context: sharedContext)
                            return permitParking
                        }
                        self.permitParkingList = permitParking
                    }
                    saveContext()
                    self.loadPermitLocation()
                }
            }
            }
        }else{
            self.loadPermitLocation()
        }
    }
    
    func getMeterParkingData(){
        
        meterParkingList = fetchAllMeters()
        
        if meterParkingList.isEmpty {
        UWSGFoodClientModel.sharedInstance().taskForGetMethod("parking/lots/meter.json", parameters: [:]){(result,error) in
            
            if error == nil {
                performUIUpdatesOnMain(){
                    if let data = result["data"] as? [[String:AnyObject]]{
                        let meterParking = data.map() {(dictionary: [String:AnyObject]) -> MeterParking in
                            let meterParking = MeterParking(dictionary: dictionary, context: sharedContext)
                            return meterParking
                        }
                        self.meterParkingList = meterParking
                    }
                    saveContext()
                    self.loadMeterLocation()
                }
            }
            }
        }else {
            self.loadMeterLocation()
        }
    }

    func loadOneParkingList(){
        if monitorParkingList.isEmpty != true {
            loadMonitorLocation()
        } else if visitorParkingList.isEmpty != true {
            loadVisitorLocation()
        }else if permitParkingList.isEmpty != true {
            loadPermitLocation()
        }else if meterParkingList.isEmpty != true {
            loadMeterLocation()
        }else{
            getMonitorParkingData()
        }
    }
    
    func loadMonitorLocation(){
        
        buildingCenter()

        for i in 0...monitorParkingList.count - 1 {
            let annotation = CustomPointAnnotation()
            annotation.title = monitorParkingList[i].lot_name
            annotation.subtitle = String(monitorParkingList[i].current_count) + "/" + String(monitorParkingList[i].capacity)
            annotation.coordinate = CLLocationCoordinate2DMake(monitorParkingList[i].latitude, monitorParkingList[i].longitude)
            annotation.imageName = "pinkishPin"
            self.mapAnnotations.append(annotation)
            self.mapView.addAnnotation(annotation)
        }
    }
    
    func loadVisitorLocation(){
        buildingCenter()

        for i in 0...visitorParkingList.count - 1 {
            let annotation = CustomPointAnnotation()
            annotation.title = visitorParkingList[i].lot_name
            annotation.subtitle = String(visitorParkingList[i].note)
            annotation.coordinate = CLLocationCoordinate2DMake(Double(visitorParkingList[i].latitude), Double(visitorParkingList[i].longitude))
            annotation.imageName = "pinkishPin"
            self.mapAnnotations.append(annotation)
            self.mapView.addAnnotation(annotation)
        }
    }
    
    func loadPermitLocation(){
        
        buildingCenter()
        for i in 0...permitParkingList.count - 1 {
            let annotation = CustomPointAnnotation()
            annotation.title = permitParkingList[i].lot_name
            annotation.subtitle = String(permitParkingList[i].description)
            annotation.coordinate = CLLocationCoordinate2DMake(Double(permitParkingList[i].latitude), Double(permitParkingList[i].longitude))
            annotation.imageName = "pinkishPin"
            self.mapAnnotations.append(annotation)
            self.mapView.addAnnotation(annotation)
        }
    }
    
    func loadMeterLocation(){

        buildingCenter()

        for i in 0...meterParkingList.count - 1 {
            let annotation = CustomPointAnnotation()
            annotation.title = meterParkingList[i].description
            annotation.coordinate = CLLocationCoordinate2DMake(Double(meterParkingList[i].latitude), Double(meterParkingList[i].longitude))
            annotation.imageName = "pinkishPin"
            self.mapAnnotations.append(annotation)
            self.mapView.addAnnotation(annotation)
        }
    }
    
    @IBAction func dismissButton(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
}
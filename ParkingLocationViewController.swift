//
//  ParkingLocationViewController.swift
//  UWSurvivalGuide
//
//  Created by Xiaochao Luo on 2016-07-08.
//  Copyright © 2016 Xiaochao Luo. All rights reserved.
//

import Foundation
import UIKit
import MapKit

class ParkingLocationViewController: UIViewController, MKMapViewDelegate {
    
    

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    
    var MonitoredSpot: MonitorParking!
    var placemark: MKPlacemark!
    var meterParking: MeterParking!
    var permitParking: PermitParking!
    var visitorParking: VisitorParking!
    var latitude: Double!
    var longitude: Double!
    var titles: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.mapType = .Hybrid
        mapView.delegate = self
        mapView.hidden = false
    }
    
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        
        if meterParking != nil {
        getAddress(Double(meterParking.latitude), longitude: Double(meterParking.longitude), title: meterParking.descriptions)
        }else if MonitoredSpot != nil {
        getAddress(MonitoredSpot.latitude, longitude: MonitoredSpot.longitude, title: MonitoredSpot.lot_name)
        }else if permitParking != nil {
            getAddress(Double(permitParking.latitude), longitude: Double(permitParking.longitude), title: permitParking.lot_name)
        }else if visitorParking != nil {
            getAddress(Double(visitorParking.latitude), longitude: Double(visitorParking.longitude), title: visitorParking.lot_name)
        }else {
            getAddress(self.latitude, longitude: self.longitude, title: self.titles ?? "")
        }

        
    }
    
    @IBAction func DismissButtonPressed(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    
    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if control == view.rightCalloutAccessoryView {
            if let selectedPin = self.placemark{
                let mapItem = MKMapItem(placemark: selectedPin)
                let launchOptions = [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving]
                mapItem.openInMapsWithLaunchOptions(launchOptions)
            }
        }
    }
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        let reuseId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId)
        
        let RunImage = UIImage(named: "direction")
        let RunButton = UIButton(type: .Custom)
        RunButton.frame = CGRectMake(0, 0, 27, 27)
        RunButton.setImage(RunImage, forState: .Normal)
        
        if pinView == nil {
            pinView = MKAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.image = UIImage(named: "pinkishPin")!
            pinView?.canShowCallout = true
            pinView?.rightCalloutAccessoryView = RunButton
        }
        else {
            pinView!.annotation = annotation
        }
        return pinView
    }
    
    func getLocation(){
        if let selectedPin = self.placemark{
            let mapItem = MKMapItem(placemark: selectedPin)
            let launchOptions = [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving]
            mapItem.openInMapsWithLaunchOptions(launchOptions)
        }
    }
    
    func getAddress(latitude: Double, longitude: Double, title: String){
        indicator.hidden = false
        indicator.startAnimating()
        CLGeocoder().reverseGeocodeLocation(CLLocation(latitude: latitude, longitude: longitude), completionHandler: {(placemarks, error) -> Void in
            
            if error != nil {
                self.indicator.hidden = true
                self.indicator.stopAnimating()
                let alertController = UIAlertController(title: "Oops!", message: "There is a Network Error", preferredStyle: .Alert)
                let OkayAction = UIAlertAction(title: "Okay", style: .Default, handler: nil)
                alertController.addAction(OkayAction)
                self.presentViewController(alertController, animated: true, completion: nil)
                self.mapView.hidden = true
                print("there is an error")
            } else {
                
            if placemarks!.count > 0 {
                self.placemark = MKPlacemark(placemark: placemarks![0])
                let annotation = MKPointAnnotation()
                annotation.coordinate = CLLocationCoordinate2DMake(latitude, longitude)
                annotation.title = "Lot" + " " + title
                annotation.subtitle = self.placemark.thoroughfare
                
                self.mapView.addAnnotation(annotation)
                let yourAnnotationAtIndex = 0
                self.mapView.selectAnnotation(self.mapView.annotations[yourAnnotationAtIndex], animated: true)
                
                let center = CLLocationCoordinate2D(latitude:latitude, longitude: longitude)
                
                let span = MKCoordinateSpanMake(0.0025, 0.0025)
                let region = MKCoordinateRegion(center: center, span: span)
                self.mapView.setRegion(region, animated: false)
                self.indicator.stopAnimating()
                self.indicator.hidden = true
                }
            }
        })
    }
        
    
}


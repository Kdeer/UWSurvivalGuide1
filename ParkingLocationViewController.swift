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
        mapView.mapType = .hybrid
        mapView.delegate = self
        mapView.isHidden = false
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
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
    
    @IBAction func DismissButtonPressed(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }
    
    override var prefersStatusBarHidden : Bool {
        return true
    }
    
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if control == view.rightCalloutAccessoryView {
            if let selectedPin = self.placemark{
                let mapItem = MKMapItem(placemark: selectedPin)
                let launchOptions = [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving]
                mapItem.openInMaps(launchOptions: launchOptions)
            }
        }
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let reuseId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId)
        
        let RunImage = UIImage(named: "direction")
        let RunButton = UIButton(type: .custom)
        RunButton.frame = CGRect(x: 0, y: 0, width: 27, height: 27)
        RunButton.setImage(RunImage, for: UIControlState())
        
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
            mapItem.openInMaps(launchOptions: launchOptions)
        }
    }
    
    func getAddress(_ latitude: Double, longitude: Double, title: String){
        indicator.isHidden = false
        indicator.startAnimating()
        CLGeocoder().reverseGeocodeLocation(CLLocation(latitude: latitude, longitude: longitude), completionHandler: {(placemarks, error) -> Void in
            
            if error != nil {
                self.indicator.isHidden = true
                self.indicator.stopAnimating()
                let alertController = UIAlertController(title: "Oops!", message: "There is a Network Error", preferredStyle: .alert)
                let OkayAction = UIAlertAction(title: "Okay", style: .default, handler: nil)
                alertController.addAction(OkayAction)
                self.present(alertController, animated: true, completion: nil)
                self.mapView.isHidden = true
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
                self.indicator.isHidden = true
                }
            }
        })
    }
        
    
}


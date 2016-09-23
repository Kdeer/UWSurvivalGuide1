//
//  FoodLocationMapViewController.swift
//  UWSurvivalGuide
//
//  Created by Xiaochao Luo on 2016-07-04.
//  Copyright © 2016 Xiaochao Luo. All rights reserved.
//

import Foundation
import UIKit
import MapKit


class FoodLocationMapViewController: UIViewController, MKMapViewDelegate{
    
    var latitude: Double = 0.0
    var longitude: Double = 0.0
    var outletsTitle : String? = nil
    
    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.mapType = .satellite
        mapView.delegate = self
    }
    
    var placemark: MKPlacemark!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = CLLocationCoordinate2DMake(self.latitude, self.longitude)
        annotation.title = self.outletsTitle
        mapView.addAnnotation(annotation)
        let yourAnnotationAtIndex = 0
        mapView.selectAnnotation(mapView.annotations[yourAnnotationAtIndex], animated: true)
        
        let center = CLLocationCoordinate2D(latitude:latitude, longitude: longitude)
        
        let span = MKCoordinateSpanMake(0.0025, 0.0025)
        let region = MKCoordinateRegion(center: center, span: span)
        mapView.setRegion(region, animated: false)
        
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if control == view.rightCalloutAccessoryView {
                            getLocation()
        }

    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {

    }
    
    func getLocation(){
        CLGeocoder().reverseGeocodeLocation(CLLocation(latitude: self.latitude, longitude: self.longitude), completionHandler: {(placemarks, error) -> Void in
            
            if error != nil {
                print("there is an error")
            }
            
            if placemarks!.count > 0 {
                self.placemark = MKPlacemark(placemark: placemarks![0])
                        if let selectedPin = self.placemark{
                            let mapItem = MKMapItem(placemark: selectedPin)
                            let launchOptions = [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving]
                            mapItem.openInMaps(launchOptions: launchOptions)
                        }
            }
        })
    }


    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        let reuseId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId)
        
        let RunImage = UIImage(named: "direction")
        let RunButton = UIButton(type: .custom)
        RunButton.frame = CGRect(x: 0, y: 0, width: 35, height: 35)
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
    
//    func getDirections(){
//        if let selectedPin = selectedPin{
//            let mapItem = MKMapItem(placemark: selectedPin)
//            let launchOptions = [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving]
//            mapItem.openInMapsWithLaunchOptions(launchOptions)
//        }
//    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
}

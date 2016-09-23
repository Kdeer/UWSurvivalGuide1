//
//  EXMapParkingLocation.swift
//  UWSurvivalGuide
//
//  Created by Xiaochao Luo on 2016-07-14.
//  Copyright © 2016 Xiaochao Luo. All rights reserved.
//

import Foundation
import UIKit
import MapKit
import CoreData


extension MapParkingLocationViewController{
    
    func buildingCenter(){
        mapView.removeAnnotations(mapAnnotations)
        if buildingPin == nil || buildingPin.latitude == nil {
            center = CLLocationCoordinate2D(latitude: 43.47096992, longitude: -80.54385066)
        }else {
            center = CLLocationCoordinate2D(latitude: Double(buildingPin.latitude), longitude: Double(buildingPin.longitude))
            let annotation = CustomPointAnnotation()
            annotation.title = buildingPin.building_name
            annotation.coordinate = CLLocationCoordinate2DMake(Double(buildingPin.latitude), Double(buildingPin.longitude))
            annotation.imageName = "blueishPin"
            self.mapAnnotations.append(annotation)
            self.mapView.addAnnotation(annotation)
            if initParkingIndicator == "Monitor"{
                let yourAnnotationAtIndex = 0
                self.mapView.selectAnnotation(self.mapView.annotations[yourAnnotationAtIndex], animated: true)
            }
        }
        let span = MKCoordinateSpanMake(0.015, 0.015)
        let region = MKCoordinateRegion(center: center, span: span)
        mapView.setRegion(region, animated: false)
        
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if control == view.rightCalloutAccessoryView{
            self.rightCallout(view.annotation!.coordinate.latitude, longitude: view.annotation!.coordinate.longitude)
        }
    }
    
    @objc(mapView:viewForAnnotation:) func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        if !(annotation is CustomPointAnnotation){
            return nil
        }
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
        
        let cpa = annotation as! CustomPointAnnotation
        pinView!.image = UIImage(named: cpa.imageName)
        return pinView
    }
    
    func rightCallout(_ latitude: Double, longitude: Double){
        CLGeocoder().reverseGeocodeLocation(CLLocation(latitude:latitude, longitude: longitude), completionHandler: {(placemarks, error) -> Void in
            
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

    
    
    
    
    
    
    
    
}

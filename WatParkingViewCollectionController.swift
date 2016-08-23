//
//  WatParkingViewCollectionController.swift
//  UWSurvivalGuide
//
//  Created by Xiaochao Luo on 2016-07-14.
//  Copyright © 2016 Xiaochao Luo. All rights reserved.
//

import Foundation
import UIKit


class WatParkingViewCollectionController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    @IBOutlet weak var mapViewParking: UIBarButtonItem!
    
    var MonitorParkingList = [MonitorParking]()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.delegate = self
        self.automaticallyAdjustsScrollViewInsets = false
        collectionView.hidden = true
        
        loadData()
    }
    
    func loadData(){
        indicator.hidden = false
        indicator.startAnimating()
        mapViewParking.enabled = false
        UWSGFoodClientModel.sharedInstance().taskForGetMethod("parking/watpark.json", parameters: [:]){(result, error) in
            
            if error == nil {
                performUIUpdatesOnMain(){
                    if let meterParkingResult = result["data"] as? [[String:AnyObject]] {
                        for item in meterParkingResult{
                            self.MonitorParkingList.append(MonitorParking(dictionary: item))
                        }
                        print(self.MonitorParkingList)
                        self.collectionView!.reloadData()
                        self.indicator.stopAnimating()
                        self.indicator.hidden = true
                        self.collectionView.hidden = false
                        self.mapViewParking.enabled = true
                    }
                }
            }else {
                self.indicator.stopAnimating()
                self.indicator.hidden = true
                let alertController = UIAlertController(title: "Oops!", message: "There is a Network Error", preferredStyle: .Alert)
                let OkayAction = UIAlertAction(title: "Okay", style: .Default, handler: nil)
                alertController.addAction(OkayAction)
                self.presentViewController(alertController, animated: true, completion: nil)
                print("wrong")
            }
            
        }
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        
        flowLayout.sectionInset = UIEdgeInsets(top: 30, left: 0, bottom: 30, right: 0)
        flowLayout.minimumInteritemSpacing = 1
        flowLayout.minimumLineSpacing = 1
        return CGSize(width: collectionView.frame.width/2.01, height: collectionView.frame.width/1.8)
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return MonitorParkingList.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("cell", forIndexPath: indexPath) as! WatParkingCollectionViewCell
        let parkingRow = MonitorParkingList[indexPath.row]
        let percentNumber = Double(MonitorParkingList[indexPath.row].percent_filled)/100
        cell.lotLabel.font = UIFont(name: "HelveticaNeue-CondensedBlack", size: 70)
        
        cell.lotLabel.text = parkingRow.lot_name
        cell.capacityLabel.text = String(parkingRow.current_count) + "/" + String(parkingRow.capacity)
        cell.progressView.hidden = false
        cell.progressView.alpha = 1
        cell.progressView.animateFromAngle(0, toAngle: 360*percentNumber, duration: 4*percentNumber){completed in
            if completed{
                cell.percentageLabel.text = String(percentNumber) + "%"
            }else {
                print("animation stopeed, was interrupted")
            }
        }
        
        return cell
    }
    
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        _ = collectionView.cellForItemAtIndexPath(indexPath) as! WatParkingCollectionViewCell
        let parkingRow = MonitorParkingList[indexPath.row]
        
        let controller = self.storyboard!.instantiateViewControllerWithIdentifier("ParkingLocationViewController") as! ParkingLocationViewController
        controller.MonitoredSpot = parkingRow
//        self.navigationController!.pushViewController(controller, animated: true)
        self.presentViewController(controller, animated: true, completion: nil)
    }
    
    @IBAction func refreshButtonPressed(sender: AnyObject) {
        if MonitorParkingList.count > 0 {
            MonitorParkingList.removeAll()
            loadData()
        }else {
            loadData()
        }
        
    }
    
    
    //change the view to the map with all the parking's lots.
    @IBAction func MapVersionButton(sender: AnyObject) {
        let controller = self.storyboard!.instantiateViewControllerWithIdentifier("MapParkingLocationViewController") as! MapParkingLocationViewController
        controller.monitorParkingList = self.MonitorParkingList
        controller.initParkingIndicator = "Monitor"
        self.presentViewController(controller, animated: true, completion: nil)
        
    }
    

    @IBAction func dismissButtonPressed(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    
    
    
    
}
//
//  FoodOutletsTableViewController.swift
//  UWSurvivalGuide
//
//  Created by Xiaochao Luo on 2016-07-06.
//  Copyright © 2016 Xiaochao Luo. All rights reserved.
//

import Foundation
import UIKit


//menu problem is not solved. solve it later
class FoodOutletsTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var outletsName: [String] = []
    var locationInfo = [LocationDict]()
    var foodOutlets = [FoodDict]()
    
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        indicator.isHidden = true
        tableView.delegate = self
        self.automaticallyAdjustsScrollViewInsets = false
                getOutlets()
        findtheLocation()
        tableView.isHidden = true
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 340
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return locationInfo.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "FoodOutletsCell", for: indexPath) as! FoodOutletsTableViewCell
        
        let outletsRow = locationInfo[(indexPath as NSIndexPath).row].outlet_name
        let realOutletRow = hardcodingOutlets(outletsRow)
        
        cell.outletsName.text = outletsRow
        cell.outletsIcon.image = UIImage(named: realOutletRow)
        
        if cell.outletsIcon.image == nil {
            cell.outletsIcon.image = UIImage(named: "unavailable")
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! FoodOutletsTableViewCell
        let controller = storyboard!.instantiateViewController(withIdentifier: "FoodOutletTableViewController") as! FoodOutletTableViewController
        controller.detailOutletImage = imageStruct(theIamge: cell.outletsIcon.image)
        controller.locationInfo1 = locationInfo[(indexPath as NSIndexPath).row]
        for i in 0...foodOutlets.count - 1 {
            
        if locationInfo[(indexPath as NSIndexPath).row].outlet_id == foodOutlets[i].outlet_id {
        controller.foodInfo = foodOutlets[i]
        }
        }
        self.navigationController!.pushViewController(controller, animated: true)
    }
    
    
    func findtheLocation(){
        indicator.startAnimating()
        indicator.isHidden = false
        UWSGFoodClientModel.sharedInstance().taskForGetMethod("foodservices/locations.json", parameters: [:]){(result,error) in
            
            if error != nil {
                print(error)
                let alertController = UIAlertController(title: "Oops!", message: "There is a Network Error", preferredStyle: .alert)
                let OkayAction = UIAlertAction(title: "Okay", style: .default, handler: nil)
                alertController.addAction(OkayAction)
                self.present(alertController, animated: true, completion: nil)
                self.indicator.isHidden = true
                self.indicator.stopAnimating()
            }else {
                self.tableView.isHidden = false
                performUIUpdatesOnMain(){
                    if let data = result?["data"] as? [[String:AnyObject]] {
                        for item in data {
                            self.locationInfo.append(LocationDict(dictionary: item))
                        }
                    }
                    
                    for i in 0...self.locationInfo.count-1{
                        self.outletsName.append(self.locationInfo[i].outlet_name)
                    }
                    print(self.outletsName)
                    self.tableView?.reloadData()
                    self.tableView.isHidden = false
                    self.indicator.isHidden = true
                    self.indicator.stopAnimating()
                }
            }
        }
        
    }
    
    func getOutlets(){
        UWSGFoodClientModel.sharedInstance().taskForGetMethod("foodservices/outlets.json", parameters: [:]){(result, error) in
            
            if error != nil {
                print(error)
            }else {
                performUIUpdatesOnMain(){
                    if let foodOutletData = result?["data"] as? [[String:AnyObject]] {
                        
                        for result in foodOutletData {
                            self.foodOutlets.append(FoodDict(dictionary: result))
                        }
                        self.tableView?.reloadData()
                    }
                }
            }
        }
        
    }
    
    func hardcodingOutlets(_ string: String) -> String{
        var string = string
        if string == "Bon Appétit - Davis Centre" {
            string = "Bon Appetit - Davis Centre"
        }else if string.range(of: "Café")?.isEmpty != true {
            let newString = string.replace("Café", withString: "Cafe")
            return newString
        }
        
        
        return string
    }
    

    
    
    
}

extension String
{
    func replace(_ target: String, withString: String) -> String
    {
        return self.replacingOccurrences(of: target, with: withString, options: NSString.CompareOptions.literal, range: nil)
    }
}

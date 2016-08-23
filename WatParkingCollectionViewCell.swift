//
//  WatParkingCollectionViewCell.swift
//  UWSurvivalGuide
//
//  Created by Xiaochao Luo on 2016-07-08.
//  Copyright © 2016 Xiaochao Luo. All rights reserved.
//

import UIKit

class WatParkingCollectionViewCell: UICollectionViewCell {
    
    
    @IBOutlet weak var progressView: KDCircularProgress!
    @IBOutlet weak var percentageLabel: UILabel!
    @IBOutlet weak var lotLabel: UILabel!
    @IBOutlet weak var capacityLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    
    
    //Meter Parking outlets
    
    @IBOutlet weak var descriptionLabel: UILabel!
    
    //Permit Parking outlets
    
    @IBOutlet weak var parkingLotLabel: UILabel!
    
    //VisitorParking outlets
    
    @IBOutlet weak var visitorParkingLabel: UILabel!
    @IBOutlet weak var visitorParkingNote: UILabel!
    
    
    
    
}

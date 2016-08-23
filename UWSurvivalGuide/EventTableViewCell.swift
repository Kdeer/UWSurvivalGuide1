//
//  EventTableViewCell.swift
//  UWSurvivalGuide
//
//  Created by Xiaochao Luo on 2016-07-16.
//  Copyright © 2016 Xiaochao Luo. All rights reserved.
//

import UIKit

class EventTableViewCell: UITableViewCell {
    
    //AllEvents
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var typeLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    
    @IBOutlet weak var expectedButton: UIButton!
    
    @IBOutlet weak var expiredLabel: UILabel!
    
    //OneSelected
    @IBOutlet weak var eventTimeLabel: UILabel!
    @IBOutlet weak var DescriptionLabel: UILabel!
    @IBOutlet weak var audienceLabel: UILabel!
    @IBOutlet weak var costLabel: UILabel!
    @IBOutlet weak var directionButton: UIButton!
    @IBOutlet weak var locationInfoLabel: UILabel!
    @IBOutlet weak var expireLabel: UILabel!
    
    //Expected
    @IBOutlet weak var exTitleLabel: UILabel!
    @IBOutlet weak var exTypeLabel: UILabel!
    @IBOutlet weak var exTimeLabel: UILabel!
    @IBOutlet weak var expiredLabel1: UILabel!
}

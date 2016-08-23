//
//  NewsTableViewCell.swift
//  UWSurvivalGuide
//
//  Created by Xiaochao Luo on 2016-07-24.
//  Copyright © 2016 Xiaochao Luo. All rights reserved.
//

import UIKit
import Foundation

class NewsTableViewCell: UITableViewCell {

    
    @IBOutlet weak var titleLabel: UILabel!
    
    
    
    @IBOutlet weak var previousButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var newsImageView: UIImageView!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    
    
    var taskToCancelifCellIsReused: NSURLSessionTask? {
        
        didSet {
            if let taskToCancel = oldValue {
                taskToCancel.cancel()
            }
        }
    }
    
    
    @IBOutlet weak var descriptionsLabel: UILabel!
    
    @IBOutlet weak var timeLabel: UILabel!
    
    @IBOutlet weak var NewsImage: UIImageView!
    
    //tableView WithOut ImageURL
    
    @IBOutlet weak var timeLabel1: UILabel!
    
    @IBOutlet weak var descriptionLabel1: UILabel!
    
    
    
}

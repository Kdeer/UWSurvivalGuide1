//
//  NewsDetailViewController1.swift
//  UWSurvivalGuide
//
//  Created by Xiaochao Luo on 2016-07-27.
//  Copyright © 2016 Xiaochao Luo. All rights reserved.
//

import Foundation
import UIKit


class NewsDetailViewController1: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var tableView: UITableView!
    
    
    var newsList: News!
    var TheNumberI: Int! = 0
    var theDataNumber: Int! = 0
    var condition = 2
    var titleLabelText = String()
    var timeLabelText = String()
    var descriptionString = String()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.automaticallyAdjustsScrollViewInsets = false
        tableView.delegate = self
        titleLabel.text = titleLabelText
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 400
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! NewsTableViewCell
        
        cell.timeLabel1.text = timeLabelText
        cell.timeLabel1.textColor = UIColor(red: 114 / 255, green: 114 / 255, blue: 114 / 255, alpha: 1.0)
        
        cell.descriptionLabel1.text = self.descriptionString
        
        
        return cell
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
}

//
//  NewsDetailViewController.swift
//  UWSurvivalGuide
//
//  Created by Xiaochao Luo on 2016-07-25.
//  Copyright © 2016 Xiaochao Luo. All rights reserved.
//

import UIKit

class NewsDetailViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    var newsList: News!
    var TheNumberI = Int()
    var TheDataNumber: Int! = 0
    var condition = 2
    var titleLabelText = String()
    var timeLabelText = String()
    var descriptionString = String()
    var imageURL = String()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.automaticallyAdjustsScrollViewInsets = false
        tableView.delegate = self
        titleLabel.text = titleLabelText
//        timeLabel.text = timeLabelText
//        timeLabel.textColor = UIColor(red: 114 / 255, green: 114 / 255, blue: 114 / 255, alpha: 1.0)
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 400
        

//        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.action, target: self, action: #selector(NewsDetailViewController.shareButtonPressed))


//        viewDidLoadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.TheNumberI = UserDefaults.standard.integer(forKey: "TheNumberI")
        print("\(self.TheNumberI) + This is in detail site")
    }
    
    func shareButtonPressed() {
        let activityViewController = UIActivityViewController(activityItems: [newsList.link], applicationActivities: nil)
        present(activityViewController, animated: true, completion: nil)
    }
    
    func viewDidLoadData(){
        tableView.delegate = self
        titleLabel.text = titleLabelText
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! NewsTableViewCell
        
        
        cell.timeLabel.text = timeLabelText
        cell.timeLabel.textColor = UIColor(red: 114 / 255, green: 114 / 255, blue: 114 / 255, alpha: 1.0)
        cell.descriptionsLabel.text = self.descriptionString
        

        cell.NewsImage.image = newsList.newsImage
        
        
        return cell
    }
    

}

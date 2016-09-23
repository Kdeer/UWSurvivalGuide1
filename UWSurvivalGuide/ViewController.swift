//
//  ViewController.swift
//  UWSurvivalGuide
//
//  Created by Xiaochao Luo on 2016-07-01.
//  Copyright © 2016 Xiaochao Luo. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var stackFlowView: UIStackView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        specialAffect()
    }
    
    func specialAffect(){
        
        self.stackFlowView.center.y = self.view.frame.height + 130
        
        UIView.animate(withDuration: 0.7, delay: 0, options: .curveEaseOut, animations: ({self.stackFlowView.center.y = self.view.frame.height/2}), completion: nil)

    }
    
    @IBAction func parkingButtonPressed(_ sender: AnyObject) {
        
        let controller = self.storyboard!.instantiateViewController(withIdentifier: "parkingTabView") as! UITabBarController
        
        self.present(controller, animated: true, completion: nil)
        
        
        
    }
    

}


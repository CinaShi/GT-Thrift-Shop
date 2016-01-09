//
//  Detected_SalaryViewController.swift
//  Edvizer
//
//  Created by Jeff Liu on 11/27/15.
//  Copyright © 2015 Appfish. All rights reserved.
//

import UIKit

class Detected_SalaryViewController: UIViewController {

    let background_color = CAGradientLayer().blueGreenColor()
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        background_color.frame = self.view.bounds
        self.view.layer.insertSublayer(background_color, atIndex: 0)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

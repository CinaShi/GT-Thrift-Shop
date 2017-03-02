//
//  FirstTimeSuccessViewController.swift
//  GTThriftShop
//
//  Created by Mengyang Shi on 1/26/17.
//  Copyright © 2017 Triple6. All rights reserved.
//

import UIKit

class FirstTimeSuccessViewController: UIViewController {
    
    @IBOutlet weak var submitButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        submitButton.layer.borderWidth = 1
        submitButton.layer.borderColor = UIColor(red: 0, green: 128/255, blue: 1, alpha: 1).cgColor
        submitButton.layer.cornerRadius = 20
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}

//
//  Account_InfoViewController.swift
//  Edvizer
//
//  Created by Jeff Liu on 11/20/15.
//  Copyright © 2015 Appfish. All rights reserved.
//

import UIKit

class Account_InfoViewController: UIViewController {

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
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

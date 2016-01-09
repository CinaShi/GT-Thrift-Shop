//
//  ViewController.swift
//  Edvizer
//
//  Created by Jeff Liu on 11/11/15.
//  Copyright © 2015 Appfish. All rights reserved.
//

import UIKit

class LogIn_RegisterViewController: UIViewController {
    
    //TextField for user to enter EMAIL
    @IBOutlet var enterEmail: UITextField!
    //TextField for user to enter Password
    @IBOutlet var enterPassword: UITextField!
    
    //Sign In Label
    @IBOutlet weak var signInLabel: UIButton!
    //Sign Up Label
    @IBOutlet weak var signUpLabel: UIButton!
    
    //Action Button for Signing In
 
    

    @IBAction func signUpButton(sender: AnyObject) {
        
        registerToBasicInfoScreen()
    }
    let background_color = CAGradientLayer().blueGreenColor()
    
    
    func registerToBasicInfoScreen() {
        
        
        let pushToAccountController = self.storyboard?.instantiateViewControllerWithIdentifier("Basic_Information") as! Basic_InfoController
        
        self.navigationController?.pushViewController(pushToAccountController, animated: true)
    }
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        

        //setting gradient background
         background_color.frame = self.view.bounds
     self.view.layer.insertSublayer(background_color, atIndex: 0)
        
        self.navigationController?.navigationBar.hidden = true
    
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        background_color.frame = self.view.bounds
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}


//
//  ChatViewController.swift
//  GTThriftShop
//
//  Created by Mengyang Shi on 11/29/16.
//  Copyright © 2016 Triple6. All rights reserved.
//

import UIKit
import FirebaseAuth
class ChatViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        loginIntoFireBase()
    }
    
    func loginIntoFireBase() {
        FIRAuth.auth()?.signInAnonymously(completion: { (anonymousUser: FIRUser?, error: NSError?) in
            if error == nil {
                print("UserId: \(anonymousUser!.uid)")
            } else {
                print(error!.localizedDescription)
                return
            }
            
            
        } as? FIRAuthResultCallback)
    }
    
    
}

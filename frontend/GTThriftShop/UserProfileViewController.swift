//
//  UserProfileViewController.swift
//  GTThriftShop
//
//  Created by Mengyang Shi on 11/29/16.
//  Copyright © 2016 Triple6. All rights reserved.
//

import UIKit

class UserProfileViewController: UIViewController {
    
    var userRating = 0
    
    @IBOutlet var stars: [UIImageView]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    
    
    @IBAction func unwindToUserProfileVC(segue: UIStoryboardSegue) {
        if segue.source is PublishmentTableViewController {
            print("unwind from publishment VC")
        } else if segue.source is TransactionHistoryTableViewController {
            print("unwind from transaction VC")
        } else if segue.source is MyCommentTableViewController {
            print("unwind from comment VC")
        }
    }
    
}

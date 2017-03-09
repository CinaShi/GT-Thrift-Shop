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
    
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var progressview: UIProgressView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        //Load Rating Score
        progressview.progress = 0
        progressview.setProgress(1, animated: true)
        
        //Load image and crop
        profileImage.layer.cornerRadius = profileImage.frame.size.width/2
        profileImage.clipsToBounds = true
        
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

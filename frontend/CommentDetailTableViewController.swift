//
//  CommentDetailTableViewController.swift
//  GTThriftShop
//
//  Created by Mengyang Shi on 3/9/17.
//  Copyright © 2017 Triple6. All rights reserved.
//

import UIKit

class CommentDetailTableViewController: UITableViewController {

    var product: Product!
    var tranId: Int!
    var commentContent: String!
    var postTime: String!
    
    @IBOutlet weak var productImageView: UIImageView!
    
    @IBOutlet weak var sellerNameLabel: UILabel!
    
    @IBOutlet weak var productNameLabel: UILabel!
    
    @IBOutlet weak var postTimeLabel: UILabel!
    
    @IBOutlet weak var commentTextView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        sellerNameLabel.text = "User: \(product.userId!)"
        productNameLabel.text = product.name
        postTimeLabel.text = "At \(postTime!)"
        commentTextView.text = commentContent
        
        if product.imageUrls.count <= 0 {
            productImageView.image = #imageLiteral(resourceName: "No Camera Filled-100")
        } else {
            DispatchQueue.main.async(execute: {
                if let imageData: NSData = NSData(contentsOf: URL(string: self.product.imageUrls.first!)!) {
                    self.productImageView.image = UIImage(data: imageData as Data)
                } else {
                    self.productImageView.image = #imageLiteral(resourceName: "No Camera Filled-100")
                }
            })
        }
    }

    
    @IBAction func unwindToPreviousPage(_ sender: Any) {
        self.performSegue(withIdentifier: "unwindToMyCommentVC", sender: self)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

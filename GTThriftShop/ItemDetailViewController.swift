//
//  ItemDetailViewController.swift
//  GTThriftShop
//
//  Created by Mengyang Shi on 11/29/16.
//  Copyright © 2016 Triple6. All rights reserved.
//

import UIKit

class ItemDetailViewController: UIViewController {
    
    var itemImage = UIImage(named:"tv")
    var productName = "Samsung 42 inch 1080P TV"
    var price = "$199"
    var owner = "Yichen Li"
    var itemDescription = "It's a used tv bought at price $300. it's kept in nearly new condition."
    
    @IBOutlet weak var favoriteImage: UIButton!
    @IBOutlet weak var itemImageView: UIImageView!
    @IBOutlet weak var nameLabelView: UILabel!
    @IBOutlet weak var priceLabelView: UILabel!
    @IBOutlet weak var ownerLabelView: UILabel!
    @IBOutlet weak var descriptionView: UITextView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        itemImageView.image = itemImage
        nameLabelView.text = productName
        priceLabelView.text = price
        ownerLabelView.text = owner
        descriptionView.text = itemDescription
    }
    
    
    @IBAction func saveFavorite(_ sender: AnyObject) {
        let defaults = UserDefaults.standard
        defaults.set("tv", forKey: "savedImage")
        defaults.set(productName, forKey: "savedName")
        defaults.set(price, forKey: "savedPrice")
        defaults.set(owner, forKey: "savedOwner")
        defaults.set("2 years", forKey: "savedYear")
        print("saved")
        favoriteImage.setImage(UIImage(named: "favorited"), for: UIControlState.normal)
    }
    
    
}

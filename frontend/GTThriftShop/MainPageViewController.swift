//
//  MainPageViewController.swift
//  GTThriftShop
//
//  Created by Mengyang Shi on 11/29/16.
//  Copyright © 2016 Triple6. All rights reserved.
//

import UIKit

class MainPageViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var hasNew = false
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        // Do any additional setup after loading the view, typically from a nib.
        self.tableView.dataSource = self
        self.tableView.delegate = self
    }
    
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        
        if userAlreadyExist(kUsernameKey: "newItemOwner") {
            hasNew = true
        } else {
            hasNew = false
        }
        
        tableView.reloadData()
        
        self.tableView.reloadData()
    }
    
    func userAlreadyExist(kUsernameKey: String) -> Bool {
        return UserDefaults.standard.object(forKey: kUsernameKey) != nil
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if !hasNew {
            return 1;
        } else {
            return 2;
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Table view cells are reused and should be dequeued using a cell identifier.
        let cellIdentifier = "mainPageItemCell"
        let cell: UITableViewCell = self.tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
        
        // Fetches the banks for the data source layout.
        let itemImage = cell.contentView.viewWithTag(5) as! UIImageView
        let itemNameLabel = cell.contentView.viewWithTag(1) as! UILabel
        let yearUsedLabel = cell.contentView.viewWithTag(2) as! UILabel
        let priceLabel = cell.contentView.viewWithTag(3) as! UILabel
        let sellerLabel = cell.contentView.viewWithTag(4) as! UILabel
        if indexPath.row == 0 {
            itemImage.image = UIImage(named: "tv")
            itemNameLabel.text = "Samsung 42 inch 1080P TV"
            yearUsedLabel.text = "2 years"
            priceLabel.text = "$199"
            sellerLabel.text = "Yichen Li"
        } else if indexPath.row == 1 {
            let defaults = UserDefaults.standard
            
            let imageData = defaults.object(forKey: "newItemImage") as! Data
            itemImage.image = UIImage(data: imageData)
            itemNameLabel.text = defaults.string(forKey: "newItemName")
            yearUsedLabel.text = defaults.string(forKey: "newItemUsedYear")
            priceLabel.text = defaults.string(forKey: "newItemPrice")
            sellerLabel.text = defaults.string(forKey: "newItemOwner")
        }
        
        
        
        return cell
    }
    
    
}

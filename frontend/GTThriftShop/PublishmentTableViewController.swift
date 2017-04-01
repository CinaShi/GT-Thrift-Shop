//
//  PublishmentTableViewController.swift
//  GTThriftShop
//
//  Created by Mengyang Shi on 3/9/17.
//  Copyright © 2017 Triple6. All rights reserved.
//

import UIKit

class PublishmentTableViewController: UITableViewController {
    var products = [Product]()
    var selected: Product?
    var userId: Int!
    var myProducts = [Product]()
    var userDefaults = UserDefaults.standard

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.navigationController?.navigationBar.isHidden = false
        myProducts.removeAll()
        
        loadProductsFromLocal()
        loadMyProducts()
        
        initialSort()
        
        tableView.reloadData()
    }

    //Mark: helper methods
    
    func loadProductsFromLocal() {
        if let decoded = userDefaults.object(forKey: "products") as? Data {
            products = NSKeyedUnarchiver.unarchiveObject(with: decoded) as! [Product]
        } else {
            notifyFailure(info: "Please connect to Internet!")
            //actually might need to manually grab data from server again here. Need opinions
        }
        
        userId = userDefaults.integer(forKey: "userId")
        
    }
    
    func loadMyProducts() {
        for product in products {
            if product.userId == userId {
                myProducts.append(product)
            }
        }
    }
    
    func initialSort() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEE, dd LLL yyyy HH:mm:ss z"
        self.myProducts.sort(by: {dateFormatter.date(from: $0.postTime)! > dateFormatter.date(from: $1.postTime)!})
    }
    
    func findProductByPid(pid: Int) -> Product? {
        for product in products {
            if product.pid! == pid {
                return product
            }
        }
        return nil
    }
    
    func notifyFailure(info: String) {
        self.sendAlart(info: info)
    }
    
    func sendAlart(info: String) {
        let alertController = UIAlertController(title: "Hey!", message: info, preferredStyle: UIAlertControllerStyle.alert)
        let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default) {
            (result : UIAlertAction) -> Void in
            print("OK")
        }
        alertController.addAction(okAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func unwindFromDetailVCtoPublishmentVC(segue: UIStoryboardSegue) {
        if segue.source is ItemDetailViewController {
            print("unwind from detail VC")
        }
    }
    
    @IBAction func backToUserProfileVC(_ sender: Any) {
        self.performSegue(withIdentifier: "unwindToUserProfileFromPublishment", sender: self)
    }
    

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return myProducts.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Table view cells are reused and should be dequeued using a cell identifier.
        let cellIdentifier = "publishmentItemCell"
        let cell: UITableViewCell = self.tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
        let currentProduct = myProducts[indexPath.row]
        // Fetches the banks for the data source layout.
        let itemImage = cell.contentView.viewWithTag(5) as! UIImageView
        let itemNameLabel = cell.contentView.viewWithTag(1) as! UILabel
        let yearUsedLabel = cell.contentView.viewWithTag(2) as! UILabel
        let priceLabel = cell.contentView.viewWithTag(3) as! UILabel
        let sellerLabel = cell.contentView.viewWithTag(4) as! UILabel
        let isSoldLabel = cell.contentView.viewWithTag(6) as! UILabel
        
        if currentProduct.imageUrls.count <= 0 {
            itemImage.image = #imageLiteral(resourceName: "No Camera Filled-100")
        } else {
            let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            let fileURL = documentsURL.appendingPathComponent("\(currentProduct.pid!)-photo1.jpeg")
            let filePath = fileURL.path
            if FileManager.default.fileExists(atPath: filePath) {
                itemImage.image = UIImage(contentsOfFile: filePath)
            } else {
                DispatchQueue.main.async(execute: {
                    
                    if let imageData: NSData = NSData(contentsOf: URL(string: currentProduct.imageUrls.first!)!) {
                        do {
                            let image = UIImage(data: imageData as Data)
                            itemImage.image = image
                            
                            try UIImageJPEGRepresentation(image!, 1)?.write(to: fileURL)
                        } catch let error as NSError {
                            print("fuk boi--> \(error)")
                        }
                        
                    } else {
                        itemImage.image = #imageLiteral(resourceName: "No Camera Filled-100")
                    }
                })
            }
        }
        itemImage.clipsToBounds = true

        
        itemNameLabel.text = currentProduct.name
        yearUsedLabel.text = "Used for \(currentProduct.usedTime!)"
        priceLabel.text = currentProduct.price
        sellerLabel.text = "Seller ID: \(currentProduct.userId!)"
        if currentProduct.isSold! {
            isSoldLabel.text = "Sold"
            isSoldLabel.textColor = .red
        } else {
            isSoldLabel.text = "On Sale"
            isSoldLabel.textColor = .green
        }
        
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        selected = myProducts[indexPath.row]
        performSegue(withIdentifier: "getItemDetailsFromPublishment", sender: nil)
        
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "getItemDetailsFromPublishment"{
            let destination = segue.destination as! ItemDetailViewController
            print(selected!.description)
            destination.product = selected!
            destination.sourceVCName = "publishmentVC"
        }
        
    }


}

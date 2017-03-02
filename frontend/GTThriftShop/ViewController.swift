//
//  ViewController.swift
//  GTThriftShop
//
//  Created by Mengyang Shi on 11/25/16.
//  Copyright © 2016 Triple6. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var loadProductsIndicator: UIActivityIndicatorView!
    
    var products = [Product]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.tableView.dataSource = self
        self.tableView.delegate = self
        
        self.navigationController?.navigationBar.isHidden = true
        
        for key in Array(UserDefaults.standard.dictionaryRepresentation().keys) {
            UserDefaults.standard.removeObject(forKey: key)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        products.removeAll()
        
        obtainAllProductsFromServer()
        
        tableView.reloadData()
        
        
    }
    
    //Mark: helper methods
    
    func obtainAllProductsFromServer() {
        loadProductsIndicator.startAnimating()
        let url = URL(string: "http://ec2-34-196-222-211.compute-1.amazonaws.com/products")
        
        var request = URLRequest(url:url! as URL)
        request.httpMethod = "GET"
        
        let task = URLSession.shared.dataTask(with: request as URLRequest) {
            data, response, error in
            
            if error != nil {
                print("error=\(error!)")
                DispatchQueue.main.async(execute: {
                    self.notifyFailure(info: "There might be some connection issue. Please try again!")
                });
                
                return
            }
            
            // You can print out response object
            print("******* response = \(response!)")
            
            // Print out reponse body
            let responseString = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
            print("****** response data = \(responseString!)")
            if let httpResponse = response as? HTTPURLResponse {
                print("***** statusCode: \(httpResponse.statusCode)")
                if httpResponse.statusCode == 200 {
                    do {
                        let json = try JSONSerialization.jsonObject(with: data!, options: []) as! Dictionary<String, Any>
                        let array = json["products"] as! [Dictionary<String, Any>]
                        // Loop through objects
                        for dict in array {
                            guard let name = dict["pName"] as? String,
                                let price = dict["pPrice"] as? String,
                                let info = dict["pInfo"] as? String,
                                let pid = dict["pid"] as? Int,
                                let postTime = dict["postTime"] as? String,
                                let usedTime = dict["usedTime"] as? String,
                                let userId = dict["userId"] as? Int,
                                let imageUrls = dict["images"] as? [String]
                                else{
                                    self.notifyFailure(info: "cannot unarchive data from server")
                                    return
                            }
//                            print("image list --> \(dict["iamges"])")
//                            var imageUrls = [String]()
//                            imageUrls.append("https://s3-us-west-2.amazonaws.com/gtthriftshopproducts/2/TI841.jpg")
                            let newProduct = Product(name: name, price: price, info: info, pid: pid, postTime: postTime, usedTime: usedTime, userId: userId, imageUrls: imageUrls)
                            self.products.append(newProduct)
                        }
                    } catch let error as NSError {
                        print("Failed to load: \(error.localizedDescription)")
                    }
                    
                    
                    DispatchQueue.main.async(execute: {
                        self.initialSort()
                        self.loadProductsIndicator.stopAnimating()
                        self.tableView.reloadData()
                    });
                } else if httpResponse.statusCode == 404 {
                    DispatchQueue.main.async(execute: {
                        self.notifyFailure(info: "Cannot connect to Internet!")
                    });
                }
                else {
                    DispatchQueue.main.async(execute: {
                        self.notifyFailure(info: "There might be some connection issue. Please try again!")
                    });
                    
                }
            } else {
                DispatchQueue.main.async(execute: {
                    self.notifyFailure(info: "There might be some connection issue. Please try again!")
                });
            }
        }
        
        task.resume()
    }
    
    func initialSort() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEE, dd LLL yyyy HH:mm:ss z"
        self.products.sort(by: {dateFormatter.date(from: $0.postTime)! > dateFormatter.date(from: $1.postTime)!})
    }
    
    func notifyFailure(info: String) {
        self.sendAlart(info: info)
        self.loadProductsIndicator.stopAnimating()
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
    
    //Mark: Table view delegate
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return products.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Table view cells are reused and should be dequeued using a cell identifier.
        let cellIdentifier = "itemCell"
        let cell: UITableViewCell = self.tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
        let currentProduct = products[indexPath.row]
        // Fetches the banks for the data source layout.
        let itemImage = cell.contentView.viewWithTag(5) as! UIImageView
        let itemNameLabel = cell.contentView.viewWithTag(1) as! UILabel
        let yearUsedLabel = cell.contentView.viewWithTag(2) as! UILabel
        let priceLabel = cell.contentView.viewWithTag(3) as! UILabel
        let sellerLabel = cell.contentView.viewWithTag(4) as! UILabel
        
        DispatchQueue.main.async(execute: {
            if let imageData: NSData = NSData(contentsOf: URL(string: currentProduct.imageUrls.first!)!) {
                itemImage.image = UIImage(data: imageData as Data)
            } else {
                itemImage.image = #imageLiteral(resourceName: "calculator")
            }
        })
        
        itemNameLabel.text = currentProduct.name
        yearUsedLabel.text = "Used for \(currentProduct.usedTime!)"
        priceLabel.text = currentProduct.price
        sellerLabel.text = "Seller ID: \(currentProduct.userId!)"
        
        
        return cell
    }
    
    @IBAction func unwindFromLoginVC(segue: UIStoryboardSegue) {
        if segue.source is LoginViewController {
            print("unwind from login VC")
        }
    }
}


//
//  ViewController.swift
//  GTThriftShop
//
//  Created by Mengyang Shi on 11/25/16.
//  Copyright © 2016 Triple6. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    private let refreshControl = UIRefreshControl()
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var loadProductsIndicator: UIActivityIndicatorView!
    
    //all products include sold and unsold products, while products include only unsold ones
    var allProducts = [Product]()
    var products = [Product]()
    
    var pageNum = 1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.tableView.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(obtainAllProductsFromServer), for: .valueChanged)
        refreshControl.attributedTitle = NSAttributedString(string: "Refreshing🤣")
        pageNum = 1
        for key in Array(UserDefaults.standard.dictionaryRepresentation().keys) {
            UserDefaults.standard.removeObject(forKey: key)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        
        obtainAllProductsFromServer()
        
        tableView.reloadData()
        
        
    }
    
    //Mark: helper methods
    
    func obtainAllProductsFromServer() {
        if !refreshControl.isRefreshing {
            loadProductsIndicator.startAnimating()
        }
        let url = URL(string: "\(GlobalHelper.sharedInstance.AWSUrlHeader)/products/page")
        
        var request = URLRequest(url:url! as URL)
        request.httpMethod = "POST"
        
        let param = [
            "pageNum"  : pageNum,
            "sortBy" : "timeLatestFirst"
        ] as [String : Any]
        
        let jsonData = try? JSONSerialization.data(withJSONObject: param)
        print("******sent param --> \(param)")
        
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData
        
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
                        if self.pageNum == 1 {
                            self.allProducts.removeAll()
                        }
                        
                        self.products.removeAll()
                        
                        
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
                                let userName = dict["nickname"] as? String,
                                let imageUrls = dict["images"] as? [String],
                                let isSold = dict["isSold"] as? Bool
                                else{
                                    self.notifyFailure(info: "cannot unarchive data from server")
                                    return
                            }
//                            print("image list --> \(dict["iamges"])")
//                            var imageUrls = [String]()
//                            imageUrls.append("https://s3-us-west-2.amazonaws.com/gtthriftshopproducts/2/TI841.jpg")
                            let newProduct = Product(name: name, price: price, info: info, pid: pid, postTime: postTime, usedTime: usedTime, userId: userId, userName: userName, imageUrls: imageUrls, isSold: isSold)
                            self.allProducts.append(newProduct)
                        }
                    } catch let error as NSError {
                        print("Failed to load: \(error.localizedDescription)")
                    }
                    
                    
                    DispatchQueue.main.async(execute: {
                        self.filterOutSoldProducts()
                        self.initialSort()
                        self.loadProductsIndicator.stopAnimating()
                        self.tableView.reloadData()
                        self.refreshControl.endRefreshing()
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
    
    func filterOutSoldProducts() {
        for product in allProducts {
            if !product.isSold {
                self.products.append(product)
            }
        }
    }
    
    func initialSort() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEE, dd LLL yyyy HH:mm:ss z"
        self.products.sort(by: {dateFormatter.date(from: $0.postTime)! > dateFormatter.date(from: $1.postTime)!})
    }
    
    func notifyFailure(info: String) {
        GlobalHelper.sendAlart(info: info, VC: self)
        self.loadProductsIndicator.stopAnimating()
        refreshControl.endRefreshing()
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
        
        itemImage.layer.cornerRadius = itemImage.frame.width/2
        itemImage.clipsToBounds = true
        
        let itemNameLabel = cell.contentView.viewWithTag(1) as! UILabel
        let yearUsedLabel = cell.contentView.viewWithTag(2) as! UILabel
        let priceLabel = cell.contentView.viewWithTag(3) as! UILabel
        let sellerLabel = cell.contentView.viewWithTag(4) as! UILabel
        
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
                            print("error--> \(error)")
                        }
                        
                    } else {
                        itemImage.image = #imageLiteral(resourceName: "No Camera Filled-100")
                    }
                })
            }
            itemImage.clipsToBounds = true

        }
        
        itemNameLabel.text = currentProduct.name
        yearUsedLabel.text = "Used for \(currentProduct.usedTime!)"
        priceLabel.text = currentProduct.price
        sellerLabel.text = "Seller: \(currentProduct.userName!)"
        
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let lastElement = products.count - 1
        if (allProducts.count % 20 == 0) && indexPath.row == lastElement {
            pageNum += 1
            obtainAllProductsFromServer()
        }
    }
    
    @IBAction func unwindFromLoginVC(segue: UIStoryboardSegue) {
        if segue.source is LoginViewController {
            print("unwind from login VC")
        }
    }
}


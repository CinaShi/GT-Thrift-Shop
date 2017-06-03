//
//  PublishmentViewController.swift
//  GTThriftShop
//
//  Created by Jihai An on 5/25/17.
//  Copyright © 2017 Triple6. All rights reserved.
//

import UIKit

class PublishmentViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var products = [Product]()
    var selected: Product?
    var userId: Int!
    var myProducts = [Product]()
    var userDefaults = UserDefaults.standard
    private let refreshControl = UIRefreshControl()
    
    var shouldRefreshData = false

    let color1 = UIColor(red: 191/255, green: 211/255, blue: 233/255, alpha: 1)
    let color2 = UIColor(red: 80/255, green: 114/255, blue: 155/255, alpha: 1)
    
    @IBOutlet weak var shadowView: UIView!
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.shadowView.layer.shadowRadius = 3
        self.shadowView.layer.shadowOpacity = 1
        self.shadowView.layer.shadowOffset = CGSize(width: 0, height: 3)
        self.shadowView.layer.shadowColor = color1.cgColor
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.refreshControl = refreshControl
        self.tableView.refreshControl?.addTarget(self, action: #selector(obtainAllProductsFromServer), for: .valueChanged)
        self.tableView.tableFooterView = UIView()

        self.tableView.layer.shadowRadius = 3
        self.tableView.layer.shadowOpacity = 1
        self.tableView.layer.shadowOffset = CGSize(width: 0, height: -1)
        self.tableView.layer.shadowColor = color1.cgColor
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.navigationController?.navigationBar.isHidden = false
        self.myProducts.removeAll()
        
        self.activityIndicatorView.startAnimating()
        
        if shouldRefreshData {
            shouldRefreshData = false
            obtainAllProductsFromServer()
        }else {
            loadProductsFromLocal()
        }
        
        loadMyProducts()
        initialSort()
        self.activityIndicatorView.stopAnimating()
        self.tableView.reloadData()
        
    }
    
    func obtainAllProductsFromServer() {
        let url = URL(string: "\(GlobalHelper.sharedInstance.AWSUrlHeader)/products")
        
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
                            let newProduct = Product(name: name, price: price, info: info, pid: pid, postTime: postTime, usedTime: usedTime, userId: userId, userName: userName, imageUrls: imageUrls, isSold: isSold)
                            self.products.append(newProduct)
                        }
                    } catch let error as NSError {
                        print("Failed to load: \(error.localizedDescription)")
                    }
                    
                    
                    DispatchQueue.main.async(execute: {
                        self.myProducts.removeAll()
                        
//                        self.loadProductsFromLocal()
                        self.loadMyProducts()
                        
                        self.initialSort()
                        
                        self.tableView.reloadData()
                        
                        self.tableView.refreshControl?.endRefreshing()
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
    
    func loadProductsFromLocal() {
        if let decoded = userDefaults.object(forKey: "products") as? Data {
            products = NSKeyedUnarchiver.unarchiveObject(with: decoded) as! [Product]
        } else {
            notifyFailure(info: "Please connect to Internet!")
            //actually might need to manually grab data from server again here. Need opinions
        }
        
        userId = userDefaults.integer(forKey: "userId")
        print("userid: \(userId)")
    }
    
    func loadMyProducts() {
        for product in products {
            if product.userId == userId {
                myProducts.append(product)
                print("appended one")
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
        GlobalHelper.sendAlart(info: info, VC: self)
        self.activityIndicatorView.stopAnimating()
        self.tableView.refreshControl?.endRefreshing()
    }
    
    
    @IBAction func unwindFromDetailVCtoPublishmentVC(segue: UIStoryboardSegue) {
        if segue.source is ItemDetailViewController {
            print("unwind from detail VC")
        }
    }
    
    @IBAction func backToUserProfileVC(_ sender: Any) {
        self.performSegue(withIdentifier: "unwindToUserProfileFromPublishment", sender: self)

    }
    //MARK table view delegates
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("count:  \(myProducts.count)")
        return myProducts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Table view cells are reused and should be dequeued using a cell identifier.
        let cellIdentifier = "publishmentItemCell"
        let cell: UITableViewCell = self.tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
        
        let currentProduct = myProducts[indexPath.row]
        print("myProducts: \(currentProduct)")
        // Fetches the banks for the data source layout.
        let itemImage = cell.contentView.viewWithTag(4) as! UIImageView
        let itemNameLabel = cell.contentView.viewWithTag(1) as! UILabel
        let priceLabel = cell.contentView.viewWithTag(2) as! UILabel
        let isSoldLabel = cell.contentView.viewWithTag(3) as! UILabel
        
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
        
        itemNameLabel.text = currentProduct.name
        priceLabel.text = "$" + currentProduct.price
        if currentProduct.isSold! {
            isSoldLabel.text = "Sold"
            isSoldLabel.textColor = .red
        } else {
            isSoldLabel.text = " "
        }
        
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
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
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}


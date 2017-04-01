//
//  MainPageViewController.swift
//  GTThriftShop
//
//  Created by Mengyang Shi on 11/29/16.
//  Copyright © 2016 Triple6. All rights reserved.
//

import UIKit

class MainPageViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    //all products include sold and unsold products, while products include only unsold ones
    var allProducts = [Product]()
    var products = [Product]()
    var selected: Product?
    var userDefaults = UserDefaults.standard
    var searchActive: Bool = false
    var menuShowing = false
    var sortViewExpanded = false
    
    @IBOutlet weak var menuView: UIView!
    @IBOutlet weak var leadingConstraint: NSLayoutConstraint!
    var filteredProducts = [Product]()
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var loadProductsIndicator: UIActivityIndicatorView!
    
    @IBOutlet var sortView: UIView!
    @IBOutlet weak var sortViewButton: UIButton!
    @IBOutlet weak var menuTableView: UITableView!
    
    var tags = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.tableView.dataSource = self
        self.tableView.delegate = self
        
        searchBar.delegate = self
        
        self.menuTableView.dataSource = self
        self.menuTableView.delegate = self
        
        
//        let tapper: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action:#selector(MainPageViewController.dismissSortView))
//        self.view.addGestureRecognizer(tapper)
        
        self.menuView.layer.shadowOpacity = 0.75
        self.menuView.layer.shadowRadius = 3
        leadingConstraint.constant = -140
        self.view.layoutIfNeeded()
        tags.append("All")
//        tags.append("Calculator")
//        tags.append("Computer")
        
        obtainTagsFromServer()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        print(tags)
        allProducts.removeAll()
        products.removeAll()
        
        obtainAllProductsFromServer()
        
        tableView.reloadData()
        
    }
    
    //Mark: helper methods
    
    func storeTagsToLocal() {
        userDefaults.set(tags, forKey: "tags")
        userDefaults.synchronize()
    }
    
    func storeProductsToLocal() {
        let productsToSave = allProducts.sorted(by: {$0.pid! < $1.pid!})
        let encodedData: Data = NSKeyedArchiver.archivedData(withRootObject: productsToSave)
        userDefaults.set(encodedData, forKey: "products")
        userDefaults.synchronize()
    }
    
    func refreshProductsFromLocal() {
        if let decoded = userDefaults.object(forKey: "products") as? Data {
            allProducts = NSKeyedUnarchiver.unarchiveObject(with: decoded) as! [Product]
            products.removeAll()
            filterOutSoldProducts()
        } else {
            notifyFailure(info: "Please connect to Internet")
            //actually might need to manually grab data from server again here. Need opinions
        }
    }
    
    func obtainTagsFromServer() {
        loadProductsIndicator.startAnimating()
        let url = URL(string: "http://ec2-34-196-222-211.compute-1.amazonaws.com/tags")
        
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
                        let array = json["tags"] as! [String]
                        for tag in array {
                            self.tags.append(tag)
                        }
                    } catch let error as NSError {
                        print("Failed to load: \(error.localizedDescription)")
                    }
                    
                    
                    DispatchQueue.main.async(execute: {
                        self.loadProductsIndicator.stopAnimating()
                        self.storeTagsToLocal()
                        self.menuTableView.reloadData()
                    });
                }else if httpResponse.statusCode == 404 {
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
                                let imageUrls = dict["images"] as? [String],
                                let isSold = dict["isSold"] as? Bool
                                else{
                                    self.notifyFailure(info: "cannot unarchive data from server")
                                    return
                            }

                            let newProduct = Product(name: name, price: price, info: info, pid: pid, postTime: postTime, usedTime: usedTime, userId: userId, imageUrls: imageUrls, isSold: isSold)
                            self.allProducts.append(newProduct)
                            
                        }
                    } catch let error as NSError {
                        print("Failed to load: \(error.localizedDescription)")
                    }
                    
                    
                    DispatchQueue.main.async(execute: {
                        self.filterOutSoldProducts()
                        
                        self.initialSort()
                        self.loadProductsIndicator.stopAnimating()
                        self.storeProductsToLocal()
                        self.tableView.reloadData()
                    });
                }else if httpResponse.statusCode == 404 {
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
    
    func getPidsByTag(tag: String) {
        loadProductsIndicator.startAnimating()
        var newTag = tag
        if tag.contains(" ") {
            newTag = tag.replacingOccurrences(of: " ", with: "_")
        }
        let url = URL(string: "http://ec2-34-196-222-211.compute-1.amazonaws.com/products/tags/\(newTag)")
        
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
                        let array = json["pids"] as! [Int]
                        DispatchQueue.main.async(execute: {
                            self.reloadTableWithTaggedPids(pids: array)
                        });
                    } catch let error as NSError {
                        print("Failed to load: \(error.localizedDescription)")
                    }
                    
                    
                    DispatchQueue.main.async(execute: {
                        self.loadProductsIndicator.stopAnimating()
                    });
                }else if httpResponse.statusCode == 404 {
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
    
    func reloadTableWithTaggedPids(pids: [Int]) {
        refreshProductsFromLocal()
        
        products = products.filter{ item in
            return pids.contains(item.pid!)
        }
        
        initialSort()
        self.tableView.reloadData()
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
    
    @IBAction func chooseSortingFunction(_ sender: Any) {
        if !sortViewExpanded {
            sortView.alpha = 0
            UIView.animate(withDuration: 0.5){
                self.sortView.alpha = 1
            }
            self.view.addSubview(sortView)
            sortView.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                NSLayoutConstraint(item: sortView, attribute: .top, relatedBy: .equal, toItem: self.view, attribute: .top, multiplier: 1.0, constant: 64),
                NSLayoutConstraint(item: sortView, attribute: .right, relatedBy: .equal, toItem: self.view, attribute: .right, multiplier: 1.0, constant: 0),
                ])
            
            UIView.animate(withDuration: 0.5, animations: {() -> Void in
                self.sortViewButton.transform = CGAffineTransform(rotationAngle: CGFloat(-M_PI_2))
            })
            sortViewExpanded = true
        } else {
            dismissSortView()
        }
    }
    
    func dismissSortView() {
        
        self.sortView.removeFromSuperview()
        UIView.animate(withDuration: 0.5, animations: {() -> Void in
            self.sortViewButton.transform = CGAffineTransform(rotationAngle: CGFloat(0))
        })
        sortViewExpanded = false
    }
    
    @IBAction func highPriceFirst(_ sender: Any) {
        products.sort(by: {Double($0.price)! > Double($1.price)!})
        self.tableView.reloadData()
    }
    
    @IBAction func lowPriceFirst(_ sender: Any) {
        products.sort(by: {Double($0.price)! < Double($1.price)!})
        self.tableView.reloadData()
    }
    
    
    @IBAction func newItemFirst(_ sender: Any) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEE, dd LLL yyyy HH:mm:ss z"
        products.sort(by: {dateFormatter.date(from: $0.postTime)! > dateFormatter.date(from: $1.postTime)!})
        self.tableView.reloadData()
    }
    
    @IBAction func oldItemFirst(_ sender: Any) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEE, dd LLL yyyy HH:mm:ss z"
        products.sort(by: {dateFormatter.date(from: $0.postTime)! < dateFormatter.date(from: $1.postTime)!})
        self.tableView.reloadData()
    }
    
    @IBAction func openMenu(_ sender: Any) {
        leadingConstraint.constant = 0
        UIView.animate(withDuration: 0.5, animations: {self.view.layoutIfNeeded()})
        menuShowing = true
    }
    
    @IBAction func closeMenu(_ sender: Any) {
        leadingConstraint.constant = -140
        UIView.animate(withDuration: 0.5, animations: {self.view.layoutIfNeeded()})
        menuShowing = false
    }
    
    @IBAction func unwindFromDetailVC(segue: UIStoryboardSegue) {
        if segue.source is ItemDetailViewController {
            print("unwind from detail VC")
        }
    }
    
    //Mark: Table view delegate
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var count:Int?
        if tableView == self.tableView {
            if searchActive {
                count = filteredProducts.count
            } else {
                count = products.count
            }
        }
        
        if tableView == self.menuTableView {
            count = tags.count
        }
        
        return count!
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Table view cells are reused and should be dequeued using a cell identifier.
        var cell:UITableViewCell?
        
        if tableView == self.tableView {
            
            let cellIdentifier = "mainPageItemCell"
            cell = self.tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
            var currentProduct = products[indexPath.row]
            if searchActive {
                currentProduct = filteredProducts[indexPath.row]
            }
            
            // Fetches the banks for the data source layout.
            let itemImage = cell?.contentView.viewWithTag(5) as! UIImageView
            let itemNameLabel = cell?.contentView.viewWithTag(1) as! UILabel
            let yearUsedLabel = cell?.contentView.viewWithTag(2) as! UILabel
            let priceLabel = cell?.contentView.viewWithTag(3) as! UILabel
            let sellerLabel = cell?.contentView.viewWithTag(4) as! UILabel
            
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
                itemImage.clipsToBounds = true


            }
            
            itemNameLabel.text = currentProduct.name
            yearUsedLabel.text = "Used for \(currentProduct.usedTime!)"
            priceLabel.text = currentProduct.price
            sellerLabel.text = "Seller ID: \(currentProduct.userId!)"
        }
        
        if tableView == self.menuTableView {
            let cellIdentifier = "menuCell"
            cell = self.menuTableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
            let tagNameLabel = cell?.contentView.viewWithTag(1) as! UILabel
            tagNameLabel.text = tags[indexPath.row]
        }
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        if tableView == self.tableView {
            print("Herererererererer")
            if searchActive {
                selected = filteredProducts[indexPath.row]
            } else {
                selected = products[indexPath.row]
            }
            performSegue(withIdentifier: "getItemDetails", sender: nil)
        }
        
        if tableView == self.menuTableView {
            closeMenu(self)
            if tags[indexPath.row] == "All" {
                self.loadProductsIndicator.startAnimating()
                refreshProductsFromLocal()
                initialSort()
                self.tableView.reloadData()
                self.loadProductsIndicator.stopAnimating()
            } else {
                getPidsByTag(tag: tags[indexPath.row])
            }
        }
    }
    
    //Mark:Search bar delegate
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchActive = true
        dismissSortView()
        searchBar.showsCancelButton = true
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchActive = false
        searchBar.showsCancelButton = false
    }
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = nil
        searchBar.endEditing(true)
        searchActive = false
        self.tableView.reloadData()
    }
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchActive = false
        self.searchBar.endEditing(true)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        filteredProducts = products.filter{ item in
            return item.name.lowercased().range(of: searchText.lowercased()) != nil
        }
        if(searchBar.text == nil || searchBar.text == "") {
            searchActive = false
        } else {
            searchActive = true
        }
        self.tableView.reloadData()
    }
    
    
    //Mark: Other delegates
    
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "getItemDetails"{
            let destination = segue.destination as! ItemDetailViewController
            print(selected!.description)
            destination.product = selected!
            destination.sourceVCName = "mainPageVC"
        }
        
    }
    
}

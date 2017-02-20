//
//  MainPageViewController.swift
//  GTThriftShop
//
//  Created by Mengyang Shi on 11/29/16.
//  Copyright © 2016 Triple6. All rights reserved.
//

import UIKit

class MainPageViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    var products = [Product]()
    var selected: Product?
    var userDefaults = UserDefaults.standard
    var searchActive: Bool = false
    var menuShowing = false
    
    @IBOutlet weak var menuView: UIView!
    @IBOutlet weak var leadingConstraint: NSLayoutConstraint!
    var filteredProducts = [Product]()
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var loadProductsIndicator: UIActivityIndicatorView!
    @IBOutlet weak var timeSorting: UIButton!
    @IBOutlet weak var priceSorting: UIButton!
    
    @IBOutlet weak var menuTableView: UITableView!
    var tags = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        // Do any additional setup after loading the view, typically from a nib.
        self.tableView.dataSource = self
        self.tableView.delegate = self
        
        searchBar.delegate = self
        
        self.menuTableView.dataSource = self
        self.menuTableView.delegate = self
        
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        self.menuView.layer.shadowOpacity = 0.75
        self.menuView.layer.shadowRadius = 3
        leadingConstraint.constant = -140
        self.view.layoutIfNeeded()
        tags.append("All")
        tags.append("Calculator")
        tags.append("Computer")
    }
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        products.removeAll()
        
        obtainAllProductsFromServer()
        
        tableView.reloadData()
        
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
    }
    
    //Mark: helper methods
    
    func storeProductsToLocal() {
        let productsToSave = products.sorted(by: {$0.pid! < $1.pid!})
        let encodedData: Data = NSKeyedArchiver.archivedData(withRootObject: productsToSave)
        userDefaults.set(encodedData, forKey: "products")
        userDefaults.synchronize()
    }
    
    func refreshProductsFromLocal() {
        if let decoded = userDefaults.object(forKey: "products") as? Data {
            products = NSKeyedUnarchiver.unarchiveObject(with: decoded) as! [Product]
        } else {
            notifyFailure(info: "Please connect to Internet")
            //actually might need to manually grab data from server again here. Need opinions
        }
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
                                let imageUrls = dict["images"] as? [String]
                                else{
                                    self.notifyFailure(info: "cannot unarchive data from server")
                                    return
                            }

                            let newProduct = Product(name: name, price: price, info: info, pid: pid, postTime: postTime, usedTime: usedTime, userId: userId, imageUrls: imageUrls)
                            self.products.append(newProduct)
                            
                        }
                    } catch let error as NSError {
                        print("Failed to load: \(error.localizedDescription)")
                    }
                    
                    
                    DispatchQueue.main.async(execute: {
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
    
    func getPidsByTag(tag: String) {
        loadProductsIndicator.startAnimating()
        let url = URL(string: "http://ec2-34-196-222-211.compute-1.amazonaws.com/products/tags/\(tag)")
        
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
    
    @IBAction func sortByPrice(_ sender: Any) {
        if priceSorting.imageView?.image == #imageLiteral(resourceName: "ascendingPrice"){
            products.sort(by: {Double($0.price)! > Double($1.price)!})
            priceSorting.setImage(#imageLiteral(resourceName: "decendingPrice"), for: UIControlState.normal)
        } else {
            products.sort(by: {Double($0.price)! < Double($1.price)!})
            priceSorting.setImage(#imageLiteral(resourceName: "ascendingPrice"), for: UIControlState.normal)
        }
        
        self.tableView.reloadData()
    }

    
    @IBAction func sortByTime(_ sender: Any) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEE, dd LLL yyyy HH:mm:ss z"
        if timeSorting.imageView?.image == #imageLiteral(resourceName: "decendingTime"){
            print("here")
            products.sort(by: {dateFormatter.date(from: $0.postTime)! < dateFormatter.date(from: $1.postTime)!})
            timeSorting.setImage(#imageLiteral(resourceName: "ascendingTime"), for: UIControlState.normal)
        } else {
            products.sort(by: {dateFormatter.date(from: $0.postTime)! > dateFormatter.date(from: $1.postTime)!})
            timeSorting.setImage(#imageLiteral(resourceName: "decendingTime"), for: UIControlState.normal)
        }
        
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
            
            if let imageData: NSData = NSData(contentsOf: URL(string: currentProduct.imageUrls.first!)!) {
                itemImage.image = UIImage(data: imageData as Data)
            } else {
                itemImage.image = #imageLiteral(resourceName: "calculator")
            }
            itemNameLabel.text = currentProduct.name
            yearUsedLabel.text = currentProduct.usedTime
            priceLabel.text = currentProduct.price
            sellerLabel.text = "user ID: \(currentProduct.userId!)"
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
            if searchActive {
                selected = filteredProducts[indexPath.row]
            } else {
                selected = products[indexPath.row]
            }
            performSegue(withIdentifier: "getItemDetails", sender: nil)
        }
        
        if tableView == self.menuTableView {
            closeMenu(self)
            print("should send url here")
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
        }
        
    }
    
}

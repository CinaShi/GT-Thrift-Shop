//
//  MainPageViewController.swift
//  GTThriftShop
//
//  Created by Mengyang Shi on 11/29/16.
//  Copyright © 2016 Triple6. All rights reserved.
//

import UIKit

class MainPageViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, UICollectionViewDelegate, UICollectionViewDataSource{
    //all products include sold and unsold products, while products include only unsold ones
    var allProducts = [Product]()
    var products = [Product]()
    var user: User!
    var selected: Product?
    var userDefaults = UserDefaults.standard
    var searchActive: Bool = false
    var menuShowing = false
    var sortViewExpanded = false
    var filteredProducts = [Product]()
    var tags = [String]()
    
    let color1 = UIColor(red: 191/255, green: 211/255, blue: 233/255, alpha: 1)
    let color2 = UIColor(red: 80/255, green: 114/255, blue: 155/255, alpha: 1)
    
    private let refreshControl = UIRefreshControl()
    
    @IBOutlet weak var menuView: UIView!
    @IBOutlet weak var leadingConstraint: NSLayoutConstraint!
    
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var loadProductsIndicator: UIActivityIndicatorView!
    
    @IBOutlet var sortView: UIView!
    @IBOutlet weak var sortViewButton: UIButton!
    @IBOutlet weak var menuTableView: UITableView!
    
    @IBOutlet weak var collectionView: UICollectionView!
    //专门放一个view来提供阴影效果
    @IBOutlet weak var shadowView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        //Starts here, collectionview
        
        let flowLayout = UICollectionViewFlowLayout.init()
        
        flowLayout.minimumLineSpacing = 20
        flowLayout.minimumInteritemSpacing = 10
        flowLayout.itemSize = CGSize(width: self.view.frame.width/2 - 20, height: self.view.frame.height/3)
        flowLayout.sectionInset = UIEdgeInsets.init(top: 15, left: 15, bottom: 15, right: 15)
        self.collectionView.collectionViewLayout = flowLayout
        
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        self.collectionView.refreshControl = refreshControl

        //ends here
        
        refreshControl.addTarget(self, action: #selector(obtainAllProductsFromServer), for: .valueChanged)
        refreshControl.tintColor = UIColor(red: 80/255, green: 114/255, blue: 155/255, alpha: 1)
        
        searchBar.delegate = self
                
        self.menuTableView.dataSource = self
        self.menuTableView.delegate = self 
        
        self.menuView.layer.shadowOpacity = 0.75
        self.menuView.layer.shadowRadius = 3
        
        leadingConstraint.constant = -300
        self.view.layoutIfNeeded()
        tags.append("All")
        
        self.sortView.layer.borderColor = color2.cgColor
        let swipeFromLeft = UISwipeGestureRecognizer(target: self, action: #selector(left(sender:)))
        swipeFromLeft.direction = .right
        let swipeFromRight = UISwipeGestureRecognizer(target: self, action: #selector(right(sender:)))
        swipeFromRight.direction = .left
        
        self.collectionView.addGestureRecognizer(swipeFromLeft)
        self.collectionView.addGestureRecognizer(swipeFromRight)
        self.collectionView.reloadData()
        
        shadowView.layer.shadowColor = color1.cgColor
        shadowView.layer.shadowRadius = 3
        shadowView.layer.shadowOffset = CGSize(width: 0.0, height: 3.0)
        shadowView.layer.shadowOpacity = 1
        
        DispatchQueue.background(background: {
            // do something in background
            if let decoded = self.userDefaults.object(forKey: "userInfo") as? Data {
                self.user = NSKeyedUnarchiver.unarchiveObject(with: decoded) as! User
            } else {
                self.getUserInfo()
            }
        
        }, completion:{
            // when background job finished, do something in main thread
            print("User info loaded")
            self.obtainTagsFromServer()
        })
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)

        searchBar.text = nil
        searchBar.endEditing(true)
        
        obtainAllProductsFromServer()
        collectionView.reloadData()
    }
    
    func getUserInfo() {
        let userId = userDefaults.integer(forKey: "userId")
        let url = URL(string: "http://ec2-34-196-222-211.compute-1.amazonaws.com/user/info/get/\(userId)")
        
        var request = URLRequest(url:url! as URL)
        request.httpMethod = "GET"
        
        let task = URLSession.shared.dataTask(with: request as URLRequest) {
            data, response, error in
            
            if error != nil {
                print("error=\(error!)")
                DispatchQueue.main.async(execute: {
                    print("Here1=========")
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
                        let json = try JSONSerialization.jsonObject(with: data!, options: []) as! Dictionary<String,Any>
                        let dict = json["userInfo"] as! Dictionary<String, Any>
                        let userImageUrl = dict["avatarURL"] as! String
                        let userDescription = dict["description"] as! String
                        let userEmail = dict["email"] as! String
                        let userNickname = dict["nickname"] as! String
                        let userRating = dict["rate"] as! Float
                        
                        self.user = User(uid: userId, nickname: userNickname, email: userEmail, info: userDescription, rate: userRating, avatarURL: userImageUrl)
                        
                        let encodedData: Data = NSKeyedArchiver.archivedData(withRootObject: self.user)
                        self.userDefaults.set(encodedData, forKey: "userInfo")
                        self.userDefaults.synchronize()
                    } catch let error as NSError {
                        print("Failed to load: \(error.localizedDescription)")
                    }
                    
                    
                    
                } else if httpResponse.statusCode == 404 {
                    DispatchQueue.main.async(execute: {
                        self.notifyFailure(info: "Cannot connect to Internet!")
                    });
                } else {
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
        if !refreshControl.isRefreshing {
            loadProductsIndicator.startAnimating()
        }
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
                        self.allProducts.removeAll()
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
                        self.collectionView.reloadData()
                        self.refreshControl.endRefreshing()
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
        self.collectionView.reloadData()
    }
    
    func initialSort() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEE, dd LLL yyyy HH:mm:ss z"
        self.products.sort(by: {dateFormatter.date(from: $0.postTime)! > dateFormatter.date(from: $1.postTime)!})
    }
    
    func notifyFailure(info: String) {
        self.sendAlart(info: info)
        self.loadProductsIndicator.stopAnimating()
        self.refreshControl.endRefreshing()
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
                NSLayoutConstraint(item: sortView, attribute: .top, relatedBy: .equal, toItem: self.view, attribute: .top, multiplier: 1.0, constant: 74),
                NSLayoutConstraint(item: sortView, attribute: .right, relatedBy: .equal, toItem: self.view, attribute: .right, multiplier: 1.0, constant: -10),
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
        self.collectionView.reloadData()
    }
    
    @IBAction func lowPriceFirst(_ sender: Any) {
        products.sort(by: {Double($0.price)! < Double($1.price)!})
        self.collectionView.reloadData()
    }
    
    
    @IBAction func newItemFirst(_ sender: Any) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEE, dd LLL yyyy HH:mm:ss z"
        products.sort(by: {dateFormatter.date(from: $0.postTime)! > dateFormatter.date(from: $1.postTime)!})
        self.collectionView.reloadData()
    }
    
    @IBAction func oldItemFirst(_ sender: Any) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEE, dd LLL yyyy HH:mm:ss z"
        products.sort(by: {dateFormatter.date(from: $0.postTime)! < dateFormatter.date(from: $1.postTime)!})
        self.collectionView.reloadData()
    }
    
    @IBAction func openMenu(_ sender: Any) {
        leadingConstraint.constant = -10

        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 3.0, options: [], animations: {self.view.layoutIfNeeded()}, completion: nil)
        
        menuShowing = true
    }
    
    @IBAction func closeMenu(_ sender: Any) {
        leadingConstraint.constant = -270
        UIView.animate(withDuration: 0.2, animations: {self.view.layoutIfNeeded()})
        
        menuShowing = false
    }
    
    func left(sender:UISwipeGestureRecognizer) {
        leadingConstraint.constant = -10
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 3.0, options: [], animations: {self.view.layoutIfNeeded()}, completion: nil)
        
        menuShowing = true
    }
    
    func right(sender: UISwipeGestureRecognizer) {
        if menuShowing == true {
            leadingConstraint.constant = -270
            UIView.animate(withDuration: 0.2, animations: {self.view.layoutIfNeeded()})
            menuShowing = false
        }
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
        count = tags.count
        print("asdfasdfsf：\(count)")
        return count!
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Table view cells are reused and should be dequeued using a cell identifier.
        var cell:UITableViewCell?
        let cellIdentifier = "menuCell"
        cell = self.menuTableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
        let tagNameLabel = cell?.contentView.viewWithTag(1) as! UILabel
        tagNameLabel.text = tags[indexPath.row]
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        
        if tableView == self.menuTableView {
            closeMenu(self)
            if tags[indexPath.row] == "All" {
                self.loadProductsIndicator.startAnimating()
                refreshProductsFromLocal()
                initialSort()
                self.collectionView.reloadData()
                self.loadProductsIndicator.stopAnimating()
            } else {
                getPidsByTag(tag: tags[indexPath.row])
            }
        }
    }
    // MARK: UICollectionviewDataSource  代理方法
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        var count:Int?
        
        if searchActive {
            count = filteredProducts.count
        } else {
            count = products.count
        }
        print("im herer:\(count)")
        return count!
    }
    
    /**
     - returns: 绘制collectionView的cell
     */
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        var cell:UICollectionViewCell?
        cell = collectionView.dequeueReusableCell(withReuseIdentifier: "mainCollectionCell", for: indexPath)
        let itemNameLabel = cell?.contentView.viewWithTag(1) as! UILabel
        let itemPriceLabel = cell?.contentView.viewWithTag(2) as! UILabel
        let itemImage = cell?.contentView.viewWithTag(3) as! UIImageView
        let shadowView2 = (cell?.contentView.viewWithTag(10))! as UIView
        
        var currentProduct = products[indexPath.row]
        if searchActive {
            currentProduct = filteredProducts[indexPath.row]
        }
        
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
        itemPriceLabel.text = currentProduct.price

        
        shadowView2.layer.shadowRadius = 5
        shadowView2.layer.shadowColor = color1.cgColor
        shadowView2.layer.shadowOpacity = 1
        shadowView2.layer.shadowOffset = CGSize(width: 0, height: 5)
        
        return cell!
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        //collectionView.deselectRow(at: indexPath, animated: false)

        if searchActive {
            selected = filteredProducts[indexPath.row]
        } else {
            selected = products[indexPath.row]
        }
        performSegue(withIdentifier: "getItemDetails", sender: nil)
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
        self.collectionView.reloadData()
    }
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = nil
        searchBar.endEditing(true)
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
        self.collectionView.reloadData()
    }
    
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

extension DispatchQueue {
    
    static func background(delay: Double = 0.0, background: (()->Void)? = nil, completion: (() -> Void)? = nil) {
        DispatchQueue.global(qos: .background).async {
            background?()
            if let completion = completion {
                DispatchQueue.main.asyncAfter(deadline: .now() + delay, execute: {
                    completion()
                })
            }
        }
    }
    
}


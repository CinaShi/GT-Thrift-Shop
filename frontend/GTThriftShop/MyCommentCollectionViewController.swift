//
//  MyCommentCollectionViewController.swift
//  GTThriftShop
//
//  Created by Jihai An on 5/24/17.
//  Copyright © 2017 Triple6. All rights reserved.
//


import UIKit

class MyCommentCollectionViewController: UICollectionViewController {
    
    var isFromAnotherUser = false
    var otherUserId:Int!
    
    var products = [Product]()
    var selected: Product?
    var selectedTranId: Int?
    var selectedCommentContent: String?
    var selectedPostTime: String?
    var selectedBuyerId: Int?
    var userId: Int!
    var myComments = [(Int, Product, Int, String, String, Int, String)]()
    var userDefaults = UserDefaults.standard
    var activityIndicatorView: UIActivityIndicatorView!
    
    let color1 = UIColor(red: 191/255, green: 211/255, blue: 233/255, alpha: 1)
    let color2 = UIColor(red: 80/255, green: 114/255, blue: 155/255, alpha: 1)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: color2]
        self.navigationController?.navigationBar.layer.shadowColor = color1.cgColor;
        self.navigationController?.navigationBar.layer.shadowOffset = CGSize(width: 0, height: 3);
        self.navigationController?.navigationBar.layer.shadowOpacity = 1;
        
        
        let flowLayout = UICollectionViewFlowLayout.init()
        flowLayout.minimumLineSpacing = 10
        flowLayout.minimumInteritemSpacing = 0
        flowLayout.itemSize = CGSize(width: self.view.frame.width - 30, height: self.view.frame.height/8)
        flowLayout.sectionInset = UIEdgeInsets.init(top: 15, left: 15, bottom: 15, right: 15)
        self.collectionView!.collectionViewLayout = flowLayout
        
        activityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
        activityIndicatorView.color = .blue
       
        self.collectionView?.backgroundView?.addSubview(activityIndicatorView)
        
        self.collectionView?.refreshControl?.addTarget(self, action: #selector(loadMyComments), for: .valueChanged)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.navigationController?.navigationBar.isHidden = false
        
        activityIndicatorView.startAnimating()
        
        if isFromAnotherUser {
            userId = otherUserId
        } else {
            userId = userDefaults.integer(forKey: "userId")
        }
        
        loadProductsFromLocal()
        loadMyComments()
        
    }
    
    //Mark: helper methods
    
    func loadProductsFromLocal() {
        if let decoded = userDefaults.object(forKey: "products") as? Data {
            products = NSKeyedUnarchiver.unarchiveObject(with: decoded) as! [Product]
        } else {
            notifyFailure(info: "Please connect to Internet!")
            //actually might need to manually grab data from server again here. Need opinions
        }
        
    }
    
    func loadMyComments() {
        //implement this part after backend API changed
        
        let url = URL(string: "http://ec2-34-196-222-211.compute-1.amazonaws.com/user/comment/get/\(userId!)")
        
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
                        self.myComments.removeAll()
                        let json = try JSONSerialization.jsonObject(with: data!, options: []) as! Dictionary<String,Any>
                        let array = json["comments"] as! [Dictionary<String, Any>]
                        // Loop through objects
                        for dict in array {
                            guard let tranId = dict["tranId"] as? Int,
                                let buyerId = dict["buyerId"] as? Int,
                                let pid = dict["pid"] as? Int,
                                let commentContent = dict["commentContent"] as? String,
                                let postTime = dict["postTime"] as? String,
                                let rate = dict["rate"] as? Int,
                                let buyerName = dict["buyerName"] as? String
                                else{
                                    self.notifyFailure(info: "cannot unarchive data from server")
                                    return
                            }
                            let product = self.findProductByPid(pid: pid)
                            
                            self.myComments.append((tranId, product!, buyerId, commentContent, postTime, rate, buyerName))
                        }
                        
                    } catch let error as NSError {
                        print("Failed to load: \(error.localizedDescription)")
                    }
                    
                    
                    DispatchQueue.main.async(execute: {
                        self.initialSort()
                        
                        self.collectionView?.reloadData()
                        self.activityIndicatorView.stopAnimating()
                        self.collectionView?.refreshControl?.endRefreshing()
                    });
                } else if httpResponse.statusCode == 400 {
                    DispatchQueue.main.async(execute: {
                        
                        if self.isFromAnotherUser {
                            self.notifyFailure(info: "There are currently no comments for this user!")
                        } else {
                            self.notifyFailure(info: "There are currently no comments for you!")
                        }
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
        self.myComments.sort(by: {dateFormatter.date(from: $0.4)! > dateFormatter.date(from: $1.4)!})
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
        self.activityIndicatorView.stopAnimating()
        self.collectionView?.refreshControl?.endRefreshing()
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
    
    
    @IBAction func unwindToUserProfile(_ sender: Any) {
        self.performSegue(withIdentifier: "unwindToUserProfileFromComment", sender: self)
    }
    
    @IBAction func unwindToMyCommentVC(segue: UIStoryboardSegue) {
        if segue.source is CommentDetailTableViewController {
            print("unwind from comment detail VC")
        }
    }
    
    // MARK: - CollectionView data source

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return myComments.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        var cell:UICollectionViewCell?
        cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CommentItemCell", for: indexPath)

        let currentComment = myComments[indexPath.row]
        let currentProduct = currentComment.1
        //let buyerId = currentComment.2
        let commentContent = currentComment.3
        let postTime = currentComment.4
        let buyerName = currentComment.6
        // Fetches the banks for the data source layout.
        let itemImage = cell?.contentView.viewWithTag(4) as! UIImageView
        let buyerLabel = cell?.contentView.viewWithTag(2) as! UILabel
        let postTimeLabel = cell?.contentView.viewWithTag(1) as! UILabel
        let commentContentTextLabel = cell?.contentView.viewWithTag(3) as! UILabel
        let shadowView = (cell?.contentView.viewWithTag(10))! as UIView
        
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
                            print("Errormessage--> \(error)")
                        }
                        
                    } else {
                        itemImage.image = #imageLiteral(resourceName: "No Camera Filled-100")
                    }
                    
                })
            }
        }
        
        buyerLabel.text = "\(buyerName)"
        
        //time convert
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEE, dd MMM yyyy HH:mm:ss z"
        let postDate = dateFormatter.date(from: postTime)
        
        dateFormatter.dateFormat = "MMM dd yyyy"
        let goodDate = dateFormatter.string(from: postDate!)
        
        postTimeLabel.text = goodDate
        commentContentTextLabel.text = commentContent
        
        shadowView.layer.shadowRadius = 5
        shadowView.layer.shadowColor = color1.cgColor
        shadowView.layer.shadowOpacity = 1
        shadowView.layer.shadowOffset = CGSize(width: 0, height: 3)
        
        return cell!
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        selected = myComments[indexPath.row].1
        selectedTranId = myComments[indexPath.row].0
        selectedCommentContent = myComments[indexPath.row].3
        selectedPostTime = myComments[indexPath.row].4
        selectedBuyerId = myComments[indexPath.row].2
        performSegue(withIdentifier: "commentDetailVC", sender: myComments[indexPath.row])
    }
    
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "commentDetailVC"{
            let navVc = segue.destination as! UINavigationController
            let destination = navVc.viewControllers.first as! CommentDetailTableViewController
            print(selected!.description)
            destination.product = selected!
            destination.tranId = selectedTranId!
            destination.commentContent = selectedCommentContent
            destination.postTime = selectedPostTime
            destination.buyerId = selectedBuyerId!
            destination.rate = (sender as! (Int, Product, Int, String, String, Int, String)).5
            destination.buyerName = (sender as! (Int, Product, Int, String, String, Int, String)).6
        }
        
    }
    
    
}

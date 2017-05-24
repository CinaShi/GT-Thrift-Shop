//
//  ItemDetailViewController.swift
//  GTThriftShop
//
//  Created by Mengyang Shi on 11/29/16.
//  Copyright © 2016 Triple6. All rights reserved.
//

import UIKit
import FirebaseDatabase

class ItemDetailViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate {
    var product: Product!
    var userId: Int!
    var user: User!
    var currentUserName: String!
    var userAvatarUrl: String!
    var isFavorited: Bool?
    var tags = [String]()
    var imageArray = [UIImage]()
    var sourceVCName: String!
    var isRated = false
    let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.light)
    let blurEffectView = UIVisualEffectView(effect: nil)
    var activityIndicatorView: UIActivityIndicatorView!
    
    var tappedImage: UIImage!
    
    private let refreshControl = UIRefreshControl()
    
    let userDefaults = UserDefaults.standard
    var interestId = [(Int,String)]()
    var interestName = [String]()
    var selectedId: Int?
    //New
    var tranId: Int!
    
    var channelRef: FIRDatabaseReference!
    
    @IBOutlet weak var interestTableView: UITableView!
    
    @IBOutlet weak var favoriteImage: UIButton!
    @IBOutlet weak var nameLabelView: UILabel!
    @IBOutlet weak var priceLabelView: UILabel!
    @IBOutlet weak var ownerLabelView: UILabel!
    @IBOutlet weak var descriptionView: UITextView!
    @IBOutlet weak var tagView: UILabel!
    @IBOutlet weak var loadDetailsIndicator: UIActivityIndicatorView!
    @IBOutlet weak var imageScrollView: UIScrollView!
    @IBOutlet weak var nextStepButton: UIButton!
    @IBOutlet weak var pageIndicator: UIPageControl!
    @IBOutlet weak var backFromInterestBlock: UIButton!
    @IBOutlet var interestBlock: UIView!
    
    @IBOutlet weak var topView: UIView!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

        interestTableView.delegate = self
        interestTableView.dataSource = self
        imageScrollView.delegate = self

        if let decoded = self.userDefaults.object(forKey: "userInfo") as? Data {
            user = NSKeyedUnarchiver.unarchiveObject(with: decoded) as! User
        } else {
            print("error: didn't get user info from local storage")
        }
        
        currentUserName = user.nickname!
        userAvatarUrl = user.avatarURL!

        var urlStrings = [String]()
        for s in product.imageUrls{
            urlStrings.append(s)
        }
        for url in urlStrings {
            if let imageData: NSData = NSData(contentsOf: URL(string: url)!) {
                imageArray.append(UIImage(data: imageData as Data)!)
            }
        }
        self.pageIndicator.numberOfPages = imageArray.count
        
        imageScrollView.frame = CGRect(x: 0, y: 20, width: self.view.frame.width, height: 300)
        for i in 0..<imageArray.count{
            let currPic = UIImageView()
            currPic.image = imageArray[i]
            currPic.contentMode = .scaleAspectFill
            let xPos = self.view.frame.width * CGFloat(i)
            currPic.frame = CGRect(x: xPos, y: 0, width: self.imageScrollView.frame.width, height: self.imageScrollView.frame.height)
            imageScrollView.contentSize.width = imageScrollView.frame.width * CGFloat(i+1)
            imageScrollView.addSubview(currPic)
            
        }
        
        if imageArray.count <= 0 {
            let currPic = UIImageView()
            currPic.image = #imageLiteral(resourceName: "No Camera Filled-100")
            currPic.contentMode = .scaleAspectFill
            let xPos = self.view.frame.width * CGFloat(0)
            currPic.frame = CGRect(x: xPos, y: 0, width: self.imageScrollView.frame.width, height: self.imageScrollView.frame.height)
            imageScrollView.contentSize.width = imageScrollView.frame.width * CGFloat(1)
            imageScrollView.addSubview(currPic)
        } else {
            tappedImage = imageArray[0]
            let imageTapped = UITapGestureRecognizer(target: self, action: #selector(enlargeImage))
            imageScrollView.addGestureRecognizer(imageTapped)
            
        }
        
        //Load Text
        let color1 = UIColor(red: 191/255, green: 211/255, blue: 233/255, alpha: 1)
        topView.layer.shadowRadius = 100
        topView.layer.masksToBounds = false
        topView.layer.shadowColor = UIColor.black.cgColor
        topView.layer.shadowOffset = CGSize(width: 0,height: 500)
        
        
        
        nameLabelView.text = product.name
        priceLabelView.text = product.price!
        ownerLabelView.text = product.userName!
        descriptionView.text = product!.info
        
        let ud = UserDefaults.standard
        userId = ud.integer(forKey: "userId")
        
        initNextStepButtonBasedOnSourceVC()
        
        loadDetailsIndicator.startAnimating()
        loadAdditionalDetails()
        
        //Button UI setup
//        nextStepButton.layer.borderWidth = 1
//        nextStepButton.layer.borderColor = UIColor(red: 0, green: 128/255, blue: 1, alpha: 1).cgColor
//        nextStepButton.layer.cornerRadius = 20
        
        channelRef = FIRDatabase.database().reference().child("Channels").child(generateChannel())
        
        if (product.userId != userId) {
            ownerLabelView.isUserInteractionEnabled = true
            let tapToUserProfile = UITapGestureRecognizer(target: self, action: #selector(goToUserProfile))
            ownerLabelView.addGestureRecognizer(tapToUserProfile)
            
        }
        
        self.interestTableView.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(loadInterestIds), for: .valueChanged)
        refreshControl.attributedTitle = NSAttributedString(string: "Refreshing🤣")
    }
    
    func initNextStepButtonBasedOnSourceVC() {
        
        if sourceVCName == "transactionVC" {
            favoriteImage.isHidden = true
            if userId == product.userId {
                nextStepButton.setTitle("Can't rate yourself :P", for: .normal)
                nextStepButton.setTitleColor(UIColor(red: 0, green: 128/255, blue: 1, alpha: 1), for: .normal)
                nextStepButton.isEnabled = false
            } else {
                if !isRated {
                    nextStepButton.setTitle("Rate and comment", for: .normal)
                    nextStepButton.addTarget(self, action: #selector(goToRateAndCommentVC), for: .touchUpInside)
                } else {
                    nextStepButton.setTitle("Already rated!", for: .normal)
                    nextStepButton.setTitleColor(UIColor(red: 0, green: 128/255, blue: 1, alpha: 1), for: .normal)
                    nextStepButton.isEnabled = false
                }
            }
        } else if userId == product.userId {
            favoriteImage.isHidden = true
            nextStepButton.setTitle("Mark as sold", for: .normal)
            nextStepButton.addTarget(self, action: #selector(markAsSold), for: .touchUpInside)
            if product.isSold! {
                nextStepButton.setTitle("Already sold!", for: .normal)
                nextStepButton.setTitleColor(UIColor(red: 0, green: 128/255, blue: 1, alpha: 1), for: .normal)
                nextStepButton.isEnabled = false
            }
        } else {
            nextStepButton.setTitle("Contact seller", for: .normal)
            nextStepButton.addTarget(self, action: #selector(goToContactSellerVC), for: .touchUpInside)
        }
        

    }
    
    func enlargeImage() {
        var imageToDisplay = tappedImage
        let imageWidth = (imageToDisplay?.size.width)!
        let imageHeight = (imageToDisplay?.size.height)!
        if imageWidth > self.view.frame.size.width || imageHeight > self.view.frame.size.height {
            if imageHeight > imageWidth {
                imageToDisplay = self.resizeImage(image: imageToDisplay!, targetSize: CGSize.init(width: imageWidth * (self.view.frame.height / imageHeight), height: self.view.frame.height))
            } else {
                imageToDisplay = self.resizeImage(image: imageToDisplay!, targetSize: CGSize.init(width: self.view.frame.width, height: imageHeight * (self.view.frame.width / imageWidth)))
            }
        }
        let newImageView = UIImageView(image: imageToDisplay)
        newImageView.frame = self.view.frame
        newImageView.backgroundColor = .black
        newImageView.contentMode = .center
        newImageView.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissFullscreenImage))
        newImageView.addGestureRecognizer(tap)
        self.view.addSubview(newImageView)
        self.view.bringSubview(toFront: newImageView)
    }
    
    func dismissFullscreenImage(_ sender: UITapGestureRecognizer) {
        self.navigationController?.navigationBar.isHidden = false
        sender.view?.removeFromSuperview()
    }
    
    func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage {
        let size = image.size
        
        let widthRatio  = targetSize.width  / image.size.width
        let heightRatio = targetSize.height / image.size.height
        
        // Figure out what our orientation is, and use that to form the rectangle
        var newSize: CGSize
        if(widthRatio > heightRatio) {
            newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
        } else {
            newSize = CGSize(width: size.width * widthRatio,  height: size.height * widthRatio)
        }
        
        // This is the rect that we've calculated out and this is what is actually used below
        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
        
        // Actually do the resizing to the rect using the ImageContext stuff
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
    
    func markAsSold() {
        // Make the block appears
        blurEffectView.frame = self.view.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(blurEffectView)
        
        
        interestBlock.center = blurEffectView.center
        interestBlock.layer.cornerRadius = 10
        blurEffectView.addSubview(interestBlock)
        interestBlock.alpha = 0
        interestBlock.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
        UIView.animate(withDuration: 0.5) {
            self.blurEffectView.effect = self.blurEffect
            self.interestBlock.alpha = 1
            self.interestBlock.transform = CGAffineTransform.identity
            
        }
        
        //send request to get all interest Id
        activityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
        activityIndicatorView.color = .blue
        interestTableView.backgroundView = activityIndicatorView
        
        if interestId.count <= 0 {
            loadInterestIds()
        }
        
    }
    
    func loadInterestIds() {
        
        activityIndicatorView.startAnimating()
        
        let url = URL(string: "http://ec2-34-196-222-211.compute-1.amazonaws.com/products/interest/\(product.pid!)")
        
        var request = URLRequest(url:url! as URL)
        request.httpMethod = "GET"
        
        
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
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
                        self.interestId.removeAll()
                        let json = try JSONSerialization.jsonObject(with: data!, options: []) as! Dictionary<String, Any>
                        let array = json["interestList"] as! [Dictionary<String, Any>]
                        for dict in array {
                            guard let interestUid = dict["userId"] as? Int,
                            let username = dict["nickname"] as? String
                            else {
                                self.notifyFailure(info: "unableToUnarchiveIds")
                                return
                            }

                            self.interestId.append((interestUid, username))
                        }

                        
                    } catch let error as NSError {
                        print("Failed to load: \(error.localizedDescription)")
                    }
                    
                    
                    DispatchQueue.main.async(execute: {
                        self.activityIndicatorView.stopAnimating()
                        self.interestTableView.reloadData()
                        self.refreshControl.endRefreshing()
                    });
                }else if httpResponse.statusCode == 400 {
                    DispatchQueue.main.async(execute: {
                        self.notifyFailure(info: "There has no one interested in this product yet!")
                        self.backFromInterestBlock(self)
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
    
    func goToUserProfile() {
        print("going to User profile")
        self.performSegue(withIdentifier: "goToUserProfile", sender: self)
    }
    
    
    //Make it disappear
    @IBAction func backFromInterestBlock(_ sender: Any) {
        
        self.interestBlock.removeFromSuperview()
        self.blurEffectView.removeFromSuperview()
        
    }
    
    func goToContactSellerVC() {
        self.performSegue(withIdentifier: "contactSellerVC", sender: self)
    }
    
    func goToRateAndCommentVC() {
        self.performSegue(withIdentifier: "rateAndCommentVC", sender: self)
    }
    
    func sendMarkAsSoldRequest() {
        //send isSold to server && dismiss interest block && make sold button un-enabled && change locally saved data
        
        self.backFromInterestBlock(self)
        self.loadDetailsIndicator.startAnimating()
        self.nextStepButton.isEnabled = false
        
        loadDetailsIndicator.startAnimating()
        let url = URL(string: "http://ec2-34-196-222-211.compute-1.amazonaws.com/products/update/isSold")
        
        var request = URLRequest(url:url! as URL)
        request.httpMethod = "POST"
        
        let param = [
            "userId"  : selectedId!,
            "pid"  : product.pid
        ]
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
                    
                    
                    DispatchQueue.main.async(execute: {
                        self.loadDetailsIndicator.stopAnimating()
                        self.nextStepButton.setTitle("Already sold!", for: .normal)
                        self.nextStepButton.setTitleColor(UIColor(red: 0, green: 128/255, blue: 1, alpha: 1), for: .normal)
                        self.nextStepButton.isEnabled = false
                        
                        self.changeLocalSaveData()
                        
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
    
    func changeLocalSaveData() {
        if let decoded = userDefaults.object(forKey: "products") as? Data {
            var products = NSKeyedUnarchiver.unarchiveObject(with: decoded) as! [Product]
            for (index, prod) in products.enumerated() {
                if prod.pid == self.product.pid {
                    prod.setSold()
                    products[index] = prod
                    let productsToSave = products.sorted(by: {$0.pid! < $1.pid!})
                    let encodedData: Data = NSKeyedArchiver.archivedData(withRootObject: productsToSave)
                    userDefaults.set(encodedData, forKey: "products")
                    userDefaults.synchronize()
                    return
                }
            }
        }
    }
    
    
    func loadAdditionalDetails() {
        loadDetailsIndicator.startAnimating()
        let url = URL(string: "http://ec2-34-196-222-211.compute-1.amazonaws.com/products/details/\(product.pid!)")
        print("http://ec2-34-196-222-211.compute-1.amazonaws.com/products/details/\(product.pid!)")
        
        var request = URLRequest(url:url! as URL)
        request.httpMethod = "POST"
        
        let param = [
            "userId"  : userId!
        ]
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
                        let json = try JSONSerialization.jsonObject(with: data!, options: []) as! Dictionary<String, Any>
                        guard let array = json["tagList"] as? [String] else {
                            self.notifyFailure(info: "unableToUnarchiveTags!")
                            return
                        }
                        for tag in array {
                            self.tags.append(tag)
                        }
                        guard let isFavorite = json["isFavorite"] as? Bool else {
                            self.notifyFailure(info: "unableToUnarchiveFavorite!")
                            return
                        }
                        self.isFavorited = isFavorite
                        
                    } catch let error as NSError {
                        print("Failed to load: \(error.localizedDescription)")
                    }
                    
                    
                    DispatchQueue.main.async(execute: {
                        self.loadDetailsIndicator.stopAnimating()
                        var tagLabel = self.tags.first
                        for tag in self.tags {
                            if tag == self.tags.first {continue}
                            tagLabel = "\(tagLabel), \(tag)"
                        }
                        self.tagView.text = tagLabel
                        if self.isFavorited! {
                            self.favoriteImage.imageView?.image = #imageLiteral(resourceName: "favorited")
                        } else {
                            self.favoriteImage.imageView?.image = #imageLiteral(resourceName: "un-favorite")
                        }
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
    
    func notifyFailure(info: String) {
        self.sendAlart(info: info)
        self.loadDetailsIndicator.stopAnimating()
        self.activityIndicatorView.stopAnimating()
        self.nextStepButton.isEnabled = true
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
    
    
    @IBAction func saveFavorite(_ sender: AnyObject) {
        guard let isFavorited = isFavorited else {
            notifyFailure(info: "Please connect to Internet first")
            return
        }
        
        var url: URL?
        if isFavorited {
            url = URL(string: "http://ec2-34-196-222-211.compute-1.amazonaws.com/favorites/remove")!
        } else {
            url = URL(string: "http://ec2-34-196-222-211.compute-1.amazonaws.com/favorites/new")!
        }
        
        var request = URLRequest(url:url! as URL)
        request.httpMethod = "POST"
        
        let param = [
            "userId"  : userId!,
            "pid"    : product.pid!
        ]
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
                    
                    DispatchQueue.main.async(execute: {
                        if self.isFavorited! {
                            self.favoriteImage.imageView?.image = #imageLiteral(resourceName: "un-favorite")
                        } else {
                            self.favoriteImage.imageView?.image = #imageLiteral(resourceName: "favorited")
                        }
                    });
                }else if httpResponse.statusCode == 404 {
                    DispatchQueue.main.async(execute: {
                        self.notifyFailure(info: "User already exists! Please login again!")
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
    
    @IBAction func backToMain(_ sender: Any) {
        if sourceVCName == "mainPageVC" {
            self.performSegue(withIdentifier: "unwindToMainPage", sender: self)
        } else if sourceVCName == "favoriteVC" {
            self.performSegue(withIdentifier: "unwindToFavorite", sender: self)
        } else if sourceVCName == "publishmentVC" {
            self.performSegue(withIdentifier: "unwindToPublishment", sender: self)
        } else if sourceVCName == "transactionVC" {
            self.performSegue(withIdentifier: "unwindToTransaction", sender: self)
        }
        
    }
    
    @IBAction func unwindToItemDetailVC(segue: UIStoryboardSegue) {
        if segue.source is ContactSellerViewController {
            print("unwind from contact VC")
        } else if segue.source is RateAndCommentTableViewController {
            print("unwind from rateAndComment VC")
            nextStepButton.setTitle("Already rated!", for: .normal)
            nextStepButton.setTitleColor(UIColor(red: 0, green: 128/255, blue: 1, alpha: 1), for: .normal)
            nextStepButton.isEnabled = false
        }
    }
    
    func generateChannel() -> String {
        return userId < product.userId! ? "\(userId!)_\(product.userId!)" : "\(product.userId!)_\(userId!)"
    }
    
    //Mark: Table view delegate
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return interestId.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Table view cells are reused and should be dequeued using a cell identifier.
        let cellIdentifier = "interestIdCell"
        let cell: UITableViewCell = self.interestTableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
        let currentId = interestId[indexPath.row]
        // Fetches the banks for the data source layout.
        let idLabel = cell.contentView.viewWithTag(1) as! UILabel
        idLabel.text = currentId.1
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        selectedId = interestId[indexPath.row].0
        sendMarkAsSoldRequest()
        
    }
    
    //Scrollview Delegate
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let pageNumber = round(imageScrollView.contentOffset.x / imageScrollView.frame.size.width)
        pageIndicator.currentPage = Int(pageNumber)
        tappedImage = imageArray[Int(pageNumber)]
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "contactSellerVC"{
            let navVc = segue.destination as! UINavigationController
            let destination = navVc.viewControllers.first as! ContactSellerViewController
            destination.userId = userId!
            destination.userName = currentUserName
            destination.userUrl = userAvatarUrl
            destination.sellerId = product.userId!
            destination.sellerName = product.userName!
            destination.pid = product.pid!
            destination.channelRef = channelRef
        } else if segue.identifier == "rateAndCommentVC" {
            //let destination = segue.destination as! RateAndCommentTableViewController
            let navBc = segue.destination as! UINavigationController
            let destination = navBc.viewControllers.first as! RateAndCommentTableViewController
            destination.userId = userId!
            destination.targetId = product.userId!
            destination.tranId = tranId!

        } else if segue.identifier == "goToUserProfile" {
            let destination = segue.destination as! UserProfileViewController
            destination.isFromOtherUser = true
            destination.otherUserId = product.userId!
        }
        
    }
    
    
    
}

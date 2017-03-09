//
//  ItemDetailViewController.swift
//  GTThriftShop
//
//  Created by Mengyang Shi on 11/29/16.
//  Copyright © 2016 Triple6. All rights reserved.
//

import UIKit

class ItemDetailViewController: UIViewController {
    var product: Product!
    var userId: Int!
    var isFavorited: Bool?
    var tags = [String]()
    var imageArray = [UIImage]()
    var sourceVCName: String!
    var isRated = false
    
    @IBOutlet weak var favoriteImage: UIButton!
    @IBOutlet weak var nameLabelView: UILabel!
    @IBOutlet weak var priceLabelView: UILabel!
    @IBOutlet weak var ownerLabelView: UILabel!
    @IBOutlet weak var descriptionView: UITextView!
    @IBOutlet weak var tagView: UILabel!
    @IBOutlet weak var loadDetailsIndicator: UIActivityIndicatorView!
    @IBOutlet weak var imageScrollView: UIScrollView!
    @IBOutlet weak var nextStepButton: UIButton!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        

        var urlStrings = [String]()
        for s in product.imageUrls{
            urlStrings.append(s)
        }
        for url in urlStrings {
            if let imageData: NSData = NSData(contentsOf: URL(string: url)!) {
                imageArray.append(UIImage(data: imageData as Data)!)
            }
        }
        
        for i in 0..<imageArray.count{
            let currPic = UIImageView()
            currPic.image = imageArray[i]
            currPic.contentMode = .scaleAspectFit
            let xPos = self.view.frame.width * CGFloat(i)
            currPic.frame = CGRect(x: xPos, y: 0, width: self.imageScrollView.frame.width, height: self.imageScrollView.frame.height)
            imageScrollView.contentSize.width = imageScrollView.frame.width * CGFloat(i+1)
            imageScrollView.addSubview(currPic)
        }
        
        //Load Text
        nameLabelView.text = product.name
        priceLabelView.text = "$\(product.price!)"
        ownerLabelView.text = "\(product.userId!)"
        descriptionView.text = product!.info
        
        let ud = UserDefaults.standard
        userId = ud.integer(forKey: "userId")
        
        initNextStepButtonBasedOnSourceVC()
        
        loadDetailsIndicator.startAnimating()
        loadAdditionalDetails()
        
        //Button UI setup
        nextStepButton.layer.borderWidth = 1
        nextStepButton.layer.borderColor = UIColor(red: 0, green: 128/255, blue: 1, alpha: 1).cgColor
        nextStepButton.layer.cornerRadius = 20
        
        
    }
    
    func initNextStepButtonBasedOnSourceVC() {
        if sourceVCName == "transactionVC" {
            if userId == product.userId {
                nextStepButton.setTitle("Can't rate yourself :P", for: .normal)
                nextStepButton.setTitleColor(.cyan, for: .normal)
                nextStepButton.isEnabled = false
            } else {
                if !isRated {
                    nextStepButton.setTitle("Rate and comment", for: .normal)
                    nextStepButton.addTarget(self, action: #selector(goToRateAndCommentVC), for: .touchUpInside)
                } else {
                    nextStepButton.setTitle("Already rated!", for: .normal)
                    nextStepButton.setTitleColor(.cyan, for: .normal)
                    nextStepButton.isEnabled = false
                }
            }
        } else if userId == product.userId {
            nextStepButton.setTitle("Mark as sold", for: .normal)
            nextStepButton.addTarget(self, action: #selector(markAsSold), for: .touchUpInside)
            if product.isSold! {
                nextStepButton.setTitle("Already sold!", for: .normal)
                nextStepButton.setTitleColor(.cyan, for: .normal)
                nextStepButton.isEnabled = false
            }
        } else {
            nextStepButton.setTitle("Contact seller", for: .normal)
            nextStepButton.addTarget(self, action: #selector(goToContactSellerVC), for: .touchUpInside)
        }
        
        loadDetailsIndicator.startAnimating()
        loadAdditionalDetails()
        
        //Button UI setup
        nextStepButton.layer.borderWidth = 1
        nextStepButton.layer.borderColor = UIColor(red: 0, green: 128/255, blue: 1, alpha: 1).cgColor
        nextStepButton.layer.cornerRadius = 20
        

    }
    
    func markAsSold() {
        print("code for markAsSold function")
    }
    
    func goToContactSellerVC() {
        self.performSegue(withIdentifier: "contactSellerVC", sender: self)
    }
    
    func goToRateAndCommentVC() {
        self.performSegue(withIdentifier: "rateAndCommentVC", sender: self)
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
        }
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "contactSellerVC"{
            let destination = segue.destination as! ContactSellerViewController
            destination.userId = userId!
            destination.pid = product.pid!
        } else if segue.identifier == "rateAndCommentVC" {
            let destination = segue.destination as! RateAndCommentTableViewController
        }
        
    }
    
    
    
}

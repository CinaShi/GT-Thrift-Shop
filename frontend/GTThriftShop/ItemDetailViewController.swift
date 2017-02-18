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
    
    @IBOutlet weak var favoriteImage: UIButton!
    @IBOutlet weak var itemImageView: UIImageView!
    @IBOutlet weak var nameLabelView: UILabel!
    @IBOutlet weak var priceLabelView: UILabel!
    @IBOutlet weak var ownerLabelView: UILabel!
    @IBOutlet weak var descriptionView: UITextView!
    @IBOutlet weak var tagView: UILabel!
    
    @IBOutlet weak var loadDetailsIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        if let imageData: NSData = NSData(contentsOf: URL(string: product.imageUrls.first!)!) {
            itemImageView.image = UIImage(data: imageData as Data)
        } else {
            itemImageView.image = #imageLiteral(resourceName: "calculator")
        }
        nameLabelView.text = product.name
        priceLabelView.text = "$\(product.price!)"
        ownerLabelView.text = "\(product.userId!)"
        descriptionView.text = product!.info
        
        let ud = UserDefaults.standard
        userId = ud.integer(forKey: "userId")
        
        loadDetailsIndicator.startAnimating()
        loadAdditionalDetails()
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
    
    
    
    
}

//
//  UserProfileViewController.swift
//  GTThriftShop
//
//  Created by Mengyang Shi on 11/29/16.
//  Copyright © 2016 Triple6. All rights reserved.
//

import UIKit

class UserProfileViewController: UIViewController {
    
    var userRating:Float = 0
    var userId: Int!
    var userDefaults = UserDefaults.standard
    
    @IBOutlet var stars: [UIImageView]!
    
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var progressview: UIProgressView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadUserFromLocal()
        changeRatingStars()
        // Do any additional setup after loading the view, typically from a nib.
        
        //Load Rating Score
        progressview.progress = 0
        progressview.setProgress(1, animated: true)
        
        //Load image and crop
        profileImage.layer.cornerRadius = profileImage.frame.size.width/2
        profileImage.clipsToBounds = true
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        getUserRating()
    }
    
    //Mark: helper methods
    
    func loadUserFromLocal() {
        userId = userDefaults.integer(forKey: "userId")
        
    }
    
    func getUserRating() {
        let url = URL(string: "http://ec2-34-196-222-211.compute-1.amazonaws.com/user/rate/get/\(userId!)")
        
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
                        let json = try JSONSerialization.jsonObject(with: data!, options: []) as! Float
                        self.userRating = json
                        
                        
                    } catch let error as NSError {
                        print("Failed to load: \(error.localizedDescription)")
                    }
                    
                    
                    DispatchQueue.main.async(execute: {
                        //deal with star here
                        self.changeRatingStars()
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
    
    func changeRatingStars() {
        if userRating <= 0 {
            for star in stars {
                star.image = #imageLiteral(resourceName: "empty-star")
            }
        } else if userRating <= 0.5 {
            for (index, star) in stars.enumerated() {
                if index == 0 {
                    star.image = #imageLiteral(resourceName: "half-star")
                } else {
                    star.image = #imageLiteral(resourceName: "empty-star")
                }
            }
        } else if userRating <= 1 {
            for (index, star) in stars.enumerated() {
                if index == 0 {
                    star.image = #imageLiteral(resourceName: "full-star")
                } else {
                    star.image = #imageLiteral(resourceName: "empty-star")
                }
            }
        } else if userRating <= 1.5 {
            for (index, star) in stars.enumerated() {
                if index == 0 {
                    star.image = #imageLiteral(resourceName: "full-star")
                } else if index == 1 {
                    star.image = #imageLiteral(resourceName: "half-star")
                } else {
                    star.image = #imageLiteral(resourceName: "empty-star")
                }
            }
        } else if userRating <= 2 {
            for (index, star) in stars.enumerated() {
                if index == 0 || index == 1 {
                    star.image = #imageLiteral(resourceName: "full-star")
                } else {
                    star.image = #imageLiteral(resourceName: "empty-star")
                }
            }
        } else if userRating <= 2.5 {
            for (index, star) in stars.enumerated() {
                if index == 0 || index == 1 {
                    star.image = #imageLiteral(resourceName: "full-star")
                } else if index == 2 {
                    star.image = #imageLiteral(resourceName: "half-star")
                } else {
                    star.image = #imageLiteral(resourceName: "empty-star")
                }
            }
        } else if userRating <= 3 {
            for (index, star) in stars.enumerated() {
                if index == 0 || index == 1 || index == 2 {
                    star.image = #imageLiteral(resourceName: "full-star")
                } else {
                    star.image = #imageLiteral(resourceName: "empty-star")
                }
            }
        } else if userRating <= 3.5 {
            for (index, star) in stars.enumerated() {
                if index == 0 || index == 1 || index == 2 {
                    star.image = #imageLiteral(resourceName: "full-star")
                } else if index == 3 {
                    star.image = #imageLiteral(resourceName: "half-star")
                } else {
                    star.image = #imageLiteral(resourceName: "empty-star")
                }
            }
        } else if userRating <= 4 {
            for (index, star) in stars.enumerated() {
                if index == 0 || index == 1 || index == 2 || index == 3 {
                    star.image = #imageLiteral(resourceName: "full-star")
                } else {
                    star.image = #imageLiteral(resourceName: "empty-star")
                }
            }
        } else if userRating <= 4.5 {
            for (index, star) in stars.enumerated() {
                if index == 0 || index == 1 || index == 2 || index == 3 {
                    star.image = #imageLiteral(resourceName: "full-star")
                } else if index == 4 {
                    star.image = #imageLiteral(resourceName: "half-star")
                } else {
                    star.image = #imageLiteral(resourceName: "empty-star")
                }
            }
        } else {
            for star in stars {
                star.image = #imageLiteral(resourceName: "full-star")
            }
        }
    }
    
    func notifyFailure(info: String) {
        self.sendAlart(info: info)
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
    
    
    
    
    @IBAction func unwindToUserProfileVC(segue: UIStoryboardSegue) {
        if segue.source is PublishmentTableViewController {
            print("unwind from publishment VC")
        } else if segue.source is TransactionHistoryTableViewController {
            print("unwind from transaction VC")
        } else if segue.source is MyCommentTableViewController {
            print("unwind from comment VC")
        }
    }
    
}

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
    let progress = KDCircularProgress(frame: CGRect(x: 0, y: 0, width: 165, height: 165))

    
    //@IBOutlet var stars: [UIImageView]!
    
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var progressview: UIProgressView!
    
    @IBOutlet weak var background: UIView!
    //@IBOutlet weak var transactionButton: UIButton!

    
    @IBOutlet weak var logoutButton: UIButton!
    
    @IBOutlet weak var buttonBlock: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()
        loadUserFromLocal()
        //changeRatingStars()
        // Do any additional setup after loading the view, typically from a nib.
        
        //Load Rating Score
        progressview.progress = 0
        
        //Load image and crop
        profileImage.layer.cornerRadius = profileImage.frame.size.width/2
        profileImage.clipsToBounds = true
        
        //background
        let color4 = UIColor(red: 127/255, green: 194/255, blue: 246/255, alpha: 1)
        background.layer.shadowColor = color4.cgColor
        background.layer.shadowRadius = 5
        background.layer.shadowOffset = CGSize(width: 0, height: 5.0)
        background.layer.shadowOpacity = 1
        
        //circular progress bar
        progress.startAngle = -90
        progress.progressThickness = 0.1
        progress.trackThickness = 0
        progress.gradientRotateSpeed = 3
        progress.roundedCorners = true
        progress.startAngle = 90
        progress.glowAmount = 1
        let color1 = UIColor(red: 255/255, green: 94/255, blue: 58/255, alpha: 1)
        let color2 = UIColor(red: 255/255, green: 42/255, blue: 104/255, alpha: 1)
        let color3 = UIColor(red: 255/255, green: 149/255, blue: 0/255, alpha: 1)
        progress.setColors(colors: color1,color2,color3)
        progress.center = CGPoint(x: profileImage.center.x - 19, y: profileImage.center.y - 15)
        progress.angle = 0
        self.view.addSubview(progress)
        
        //deal with button
        buttonBlock.layer.shadowColor = UIColor.darkGray.cgColor
        buttonBlock.layer.shadowRadius = 5
        buttonBlock.layer.shadowOffset = CGSize(width: 5.0, height: 5.0)
        buttonBlock.layer.shadowOpacity = 0.5
        
        logoutButton.layer.shadowColor = UIColor.darkGray.cgColor
        logoutButton.layer.shadowRadius = 5
        logoutButton.layer.shadowOffset = CGSize(width: 5.0, height: 5.0)
        logoutButton.layer.shadowOpacity = 0.5
        
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
                        let json = try JSONSerialization.jsonObject(with: data!, options: []) as! Dictionary<String,Any>
                        self.userRating = (json["rate"] as? Float)!

                    } catch let error as NSError {
                        print("Failed to load: \(error.localizedDescription)")
                    }
                    
                    
                    DispatchQueue.main.async(execute: {
                        //deal with star here
                        //self.changeRatingStars()
                        //self.progressview.setProgress(self.userRating/5.0, animated: true)
                        self.progress.animate(toAngle: 240, duration: 5, completion: nil)

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
    
//    func changeRatingStars() {
//        if userRating <= 0 {
//            for star in stars {
//                star.image = #imageLiteral(resourceName: "empty-star")
//            }
//        } else if userRating <= 0.5 {
//            for (index, star) in stars.enumerated() {
//                if index == 0 {
//                    star.image = #imageLiteral(resourceName: "half-star")
//                } else {
//                    star.image = #imageLiteral(resourceName: "empty-star")
//                }
//            }
//        } else if userRating <= 1 {
//            for (index, star) in stars.enumerated() {
//                if index == 0 {
//                    star.image = #imageLiteral(resourceName: "full-star")
//                } else {
//                    star.image = #imageLiteral(resourceName: "empty-star")
//                }
//            }
//        } else if userRating <= 1.5 {
//            for (index, star) in stars.enumerated() {
//                if index == 0 {
//                    star.image = #imageLiteral(resourceName: "full-star")
//                } else if index == 1 {
//                    star.image = #imageLiteral(resourceName: "half-star")
//                } else {
//                    star.image = #imageLiteral(resourceName: "empty-star")
//                }
//            }
//        } else if userRating <= 2 {
//            for (index, star) in stars.enumerated() {
//                if index == 0 || index == 1 {
//                    star.image = #imageLiteral(resourceName: "full-star")
//                } else {
//                    star.image = #imageLiteral(resourceName: "empty-star")
//                }
//            }
//        } else if userRating <= 2.5 {
//            for (index, star) in stars.enumerated() {
//                if index == 0 || index == 1 {
//                    star.image = #imageLiteral(resourceName: "full-star")
//                } else if index == 2 {
//                    star.image = #imageLiteral(resourceName: "half-star")
//                } else {
//                    star.image = #imageLiteral(resourceName: "empty-star")
//                }
//            }
//        } else if userRating <= 3 {
//            for (index, star) in stars.enumerated() {
//                if index == 0 || index == 1 || index == 2 {
//                    star.image = #imageLiteral(resourceName: "full-star")
//                } else {
//                    star.image = #imageLiteral(resourceName: "empty-star")
//                }
//            }
//        } else if userRating <= 3.5 {
//            for (index, star) in stars.enumerated() {
//                if index == 0 || index == 1 || index == 2 {
//                    star.image = #imageLiteral(resourceName: "full-star")
//                } else if index == 3 {
//                    star.image = #imageLiteral(resourceName: "half-star")
//                } else {
//                    star.image = #imageLiteral(resourceName: "empty-star")
//                }
//            }
//        } else if userRating <= 4 {
//            for (index, star) in stars.enumerated() {
//                if index == 0 || index == 1 || index == 2 || index == 3 {
//                    star.image = #imageLiteral(resourceName: "full-star")
//                } else {
//                    star.image = #imageLiteral(resourceName: "empty-star")
//                }
//            }
//        } else if userRating <= 4.5 {
//            for (index, star) in stars.enumerated() {
//                if index == 0 || index == 1 || index == 2 || index == 3 {
//                    star.image = #imageLiteral(resourceName: "full-star")
//                } else if index == 4 {
//                    star.image = #imageLiteral(resourceName: "half-star")
//                } else {
//                    star.image = #imageLiteral(resourceName: "empty-star")
//                }
//            }
//        } else {
//            for star in stars {
//                star.image = #imageLiteral(resourceName: "full-star")
//            }
//        }
//    }
    
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

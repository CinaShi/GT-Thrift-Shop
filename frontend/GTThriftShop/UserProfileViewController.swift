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
    @IBOutlet weak var background: UIView!
    @IBOutlet weak var logoutButton: UIButton!
    //starts here
    
    @IBOutlet weak var blurEffectViewTop: UIView!
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var buttonBlock: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadUserFromLocal()
        //changeRatingStars()
        // Do any additional setup after loading the view, typically from a nib.
        
        
        //Load image and crop
        profileImage.layer.cornerRadius = profileImage.frame.size.width/2
        profileImage.clipsToBounds = true
        
        //background
        let color4 = UIColor(red: 127/255, green: 194/255, blue: 246/255, alpha: 1)
        blurEffectViewTop.layer.shadowColor = color4.cgColor
        blurEffectViewTop.layer.shadowRadius = 5
        blurEffectViewTop.layer.shadowOffset = CGSize(width: 0, height: 5.0)
        blurEffectViewTop.layer.shadowOpacity = 1

        
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
        progress.center = CGPoint(x: profileImage.center.x, y: profileImage.center.y)
        progress.angle = 0
        self.view.addSubview(progress)
        print("progressbar frame: \(progress.frame)")
        print("picture frame: \(profileImage.frame)")
        print("progress center: \(progress.center)")
        
        //deal with button
        buttonBlock.layer.shadowColor = UIColor.darkGray.cgColor
        buttonBlock.layer.shadowRadius = 5
        buttonBlock.layer.shadowOffset = CGSize(width: 5.0, height: 5.0)
        buttonBlock.layer.shadowOpacity = 0.5
        
        let color5 = UIColor(red: 255/255, green: 94/255, blue: 58/255, alpha: 1)
        logoutButton.layer.cornerRadius = 20
        logoutButton.layer.borderColor = color5.cgColor
        logoutButton.layer.borderWidth = 1
        
        //scoreLabel
        self.scoreLabel.center.x = self.view.frame.width - 60
        self.scoreLabel.center.y = -30
        
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
                        if self.userRating <= 2.5 {
                            self.scoreLabel.center.x = 60
                        }
                        self.progress.animate(toAngle: Double(self.userRating / 5) * 360, duration: 2, completion: nil)
                        UIView.animate(withDuration: 2, delay: 1, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: [.curveEaseOut], animations: ({
                            self.scoreLabel.text = "Score: " + String(self.userRating) + "/5.0"
                            if (self.userRating <= 1.25 || self.userRating >= 3.75) {
                                self.scoreLabel.center.y = 147
                            } else {
                                self.scoreLabel.center.y = 73
                            }

                        }), completion: nil)

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
    
    
    @IBAction func showLogout(_ sender: Any) {
        let alert = UIAlertController(title: nil, message: "Are you sure you want to log out?", preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Log out", style: .destructive, handler: { _ in self.logout() }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
        print("================")
        
    }
    
    func logout() {
        
        HttpClient.clearCookies()
        
        LoginViewController.authFormPost = nil
        LoginViewController.authLTPost = nil
        
        self.performSegue(withIdentifier: "logout", sender: nil)

//        UserDefaults.resetStandardUserDefaults()
//        self.view.layoutIfNeeded()
//        Class.updateShortcutItems()
        
        
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

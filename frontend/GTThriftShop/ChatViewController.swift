//
//  ChatViewController.swift
//  GTThriftShop
//
//  Created by Mengyang Shi on 11/29/16.
//  Copyright © 2016 Triple6. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import Alamofire

class ChatViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    
    
    
    var currentUser: User!
    var users = [(Int, String, String)]()
    var userId: Int!
    
    var selectedUserId: Int!
    
    private let refreshControl = UIRefreshControl()
    let color1 = UIColor(red: 191/255, green: 211/255, blue: 233/255, alpha: 1)
    let color2 = UIColor(red: 80/255, green: 114/255, blue: 155/255, alpha: 1)
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var shadowView: UIView!
    @IBOutlet weak var loadUsersIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.shadowView.layer.shadowRadius = 3
        self.shadowView.layer.shadowOpacity = 1
        self.shadowView.layer.shadowOffset = CGSize(width: 0, height: 3)
        self.shadowView.layer.shadowColor = color1.cgColor
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(getUsers), for: .valueChanged)
        refreshControl.tintColor = color2
        
        self.tableView.layer.shadowRadius = 3
        self.tableView.layer.shadowOpacity = 1
        self.tableView.layer.shadowOffset = CGSize(width: 0, height: -1)
        self.tableView.layer.shadowColor = color1.cgColor
        self.tableView.tableFooterView = UIView()
        
        let ud = UserDefaults.standard
        userId = ud.integer(forKey: "userId")
        
        if let decoded = ud.object(forKey: "userInfo") as? Data {
            currentUser = NSKeyedUnarchiver.unarchiveObject(with: decoded) as! User
        } else {
            print("error: didn't get user info from local storage")
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        getUsers()
    }
    
    func getUsers() {
        if !refreshControl.isRefreshing {
            loadUsersIndicator.startAnimating()
        }
        let param = [
            "userId"  : UserDefaults.standard.string(forKey: "userId")!,
            "token" : UserDefaults.standard.string(forKey: "token")!
        ]
        Alamofire.request("\(GlobalHelper.sharedInstance.AWSUrlHeader)/products/getInterest", method: .post, parameters: param, encoding: JSONEncoding.default).validate().responseJSON { response in
            switch response.result {
            case .success:
                print("Validation Successful")
                if let json = response.result.value {
                    self.users.removeAll()
                    print("JSON: \(json)")
                    let result = json as! NSDictionary
                    let array = result["Interest"] as! [Dictionary<String, Any>]
                    for dict in array {
                        guard let userAvatarURL = dict["avatarURL"] as? String,
                            let contactUserId = dict["userId"] as? Int,
                            let username = dict["username"] as? String
                            else {
                                print("error: cannot unarchive returned data")
                                return
                        }
                        
                        self.users.append((contactUserId, username, userAvatarURL))
                    }
                    DispatchQueue.main.async(execute: {
                        self.loadUsersIndicator.stopAnimating()
                        self.tableView.reloadData()
                        self.refreshControl.endRefreshing()
                    });
                } else {
                    self.notifyFailure(info: "Failed to decode json!")
                }
            case .failure(let error):
                print(error)
                self.notifyFailure(info: "Cannot connect to server!")
            }
        }
        
    }
    
    func goToUserProfile(sender: UITapGestureRecognizer) {
        print("going to User profile")
        let touch = sender.location(in: self.tableView)
        if let indexPath = tableView.indexPathForRow(at: touch) {
            selectedUserId = users[indexPath.row].0
            self.performSegue(withIdentifier: "chatToUserProfile", sender: self)
        }
        
    }
    
    func notifyFailure(info: String) {
        GlobalHelper.sendAlart(info: info, VC: self)
        self.loadUsersIndicator.stopAnimating()
        self.refreshControl.endRefreshing()
    }
    
    
    func generateChannel(anotherId: Int) -> String {
        return userId < anotherId ? "\(userId!)_\(anotherId)" : "\(anotherId)_\(userId!)"
    }
    
    //Mark: Table view delegate
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Table view cells are reused and should be dequeued using a cell identifier.
        let cellIdentifier = "userChatCell"
        let cell: UITableViewCell = self.tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
        let currentUser = users[indexPath.row]
        // Fetches the banks for the data source layout.
        let userAvatar = cell.contentView.viewWithTag(2) as! UIImageView
        userAvatar.layer.cornerRadius = userAvatar.frame.width/2
        userAvatar.contentMode = .scaleAspectFill
        
        let userNameLabel = cell.contentView.viewWithTag(1) as! UILabel
        
        userNameLabel.text = currentUser.1
        
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let fileURL = documentsURL.appendingPathComponent("\(currentUser.0)-avatar.jpeg")
        let filePath = fileURL.path
        if FileManager.default.fileExists(atPath: filePath) {
            userAvatar.image = UIImage(contentsOfFile: filePath)
        } else {
            DispatchQueue.main.async(execute: {
                
                if let imageData: NSData = NSData(contentsOf: URL(string: currentUser.2)!) {
                    do {
                        let image = UIImage(data: imageData as Data)
                        userAvatar.image = image
                        
                        try UIImageJPEGRepresentation(image!, 1)?.write(to: fileURL)
                    } catch let error as NSError {
                        print("fuk boi--> \(error)")
                    }
                    
                } else {
                    userAvatar.image = #imageLiteral(resourceName: "GT-icon")
                }
                
            })
        }
        userAvatar.clipsToBounds = true
        
        userAvatar.isUserInteractionEnabled = true
        let tapToUserProfile = UITapGestureRecognizer(target: self, action: #selector(goToUserProfile))
        userAvatar.addGestureRecognizer(tapToUserProfile)
        
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        self.performSegue(withIdentifier: "chatVC", sender: users[indexPath.row])
        
    }
    
    
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "chatVC"{
            let navVc = segue.destination as! UINavigationController
            let destination = navVc.viewControllers.first as! ContactSellerViewController
            destination.userId = userId!
            destination.userName = currentUser.nickname
            destination.userUrl = currentUser.avatarURL
            destination.sellerName = (sender as! (Int, String, String)).1
            destination.sellerId = (sender as! (Int, String, String)).0
            destination.sellerUrl = (sender as! (Int, String, String)).2
            destination.pid = -1
            destination.channelRef = FIRDatabase.database().reference().child("Channels").child(generateChannel(anotherId: (sender as! (Int, String, String)).0))
        } else if segue.identifier == "chatToUserProfile" {
            let destination = segue.destination as! UserProfileViewController
            destination.isFromOtherUser = true
            destination.otherUserId = selectedUserId
        }
        
    }
    
}

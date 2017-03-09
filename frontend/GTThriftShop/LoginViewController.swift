//
//  LoginViewController.swift
//  GTThriftShop
//
//  Created by Mengyang Shi on 11/29/16.
//  Copyright © 2016 Triple6. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController, UITextFieldDelegate {
    
    static var authFormPost: String?
    static var authLTPost: String?
    var userIdString = String()
    var effect: UIVisualEffect!
    
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var loginActivityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var background: UIImageView!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet var loginBlock: UIView!
    @IBOutlet weak var loginBlockBlur: UIVisualEffectView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        usernameField.delegate = self
        passwordField.delegate = self
        self.navigationController?.navigationBar.isHidden = true
        
        
        effect = loginBlockBlur.effect
        loginBlockBlur.effect = nil
        
        loginBlock.layer.cornerRadius = 10
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action:#selector(LoginViewController.animateIn))
        self.view.addGestureRecognizer(tap)
        
        
        loginButton.layer.cornerRadius = 5
        backButton.layer.cornerRadius = 5
    }
    

    func animateIn() {
        self.view.addSubview(loginBlock)
        loginBlock.center = self.view.center
        loginBlock.transform = CGAffineTransform.init(scaleX: 1.3, y: 1.3)
        loginBlock.alpha = 0
        
        UIView.animate(withDuration: 0.5) {
            self.loginBlockBlur.effect = self.effect
            self.loginBlock.alpha = 1
            self.loginBlock.transform = CGAffineTransform.identity
        }

    }
    //below are functions
    
    
    @IBAction func login(_ sender: Any) {
        if usernameField.text! == "" || passwordField.text! == ""  {
            sendAlart(info: "Please fill in all blank fields before login!")
        } else {
            loginActivityIndicator.startAnimating()
            self.loginToGT()
        }
    }
    
//below are helper methods
    
    func loginToGT() {
        let client = HttpClient(url: "https://login.gatech.edu/cas/login?service=https%3A%2F%2Ft-square.gatech.edu%2Fsakai-login-tool%2Fcontainer")
        guard let loginScreenText = client.sendGet() else {
            //notify connection failure
            DispatchQueue.main.async(execute: {
                self.notifyFailure(info: "There might be some connection issue. Please try again!")
            });
            return
        }
        
        
        
        let loginScreen = loginScreenText as NSString
        
        var formPost: String
        var LT: String
        
        var user = usernameField.text!
        var password = passwordField.text!
        
        //get page form
        let pageFormInfo = HttpClient.getInfoFromPage(loginScreen, infoSearch: "<form id=\"fm1\" class=\"fm-v clearfix\" action=\"")
        let LT_info = HttpClient.getInfoFromPage(loginScreen, infoSearch: "value=\"LT")
        
        if let previousFormPost = LoginViewController.authFormPost {
            formPost = previousFormPost
        } else if let pageFormAddress = pageFormInfo {
            formPost = pageFormAddress
            LoginViewController.authFormPost = formPost
        } else {
            //notify failure
            DispatchQueue.main.async(execute: {
                self.notifyFailure(info: "There might be some connection issue. Please try again!")
            });
            return
        }
        
        //get LT
        if let previousLT = LoginViewController.authLTPost {
            LT = previousLT
        } else if let LT_part = LT_info {
            LT = "LT" + LT_part
            
            LoginViewController.authLTPost = LT
        } else {
            //notify failure
            DispatchQueue.main.async(execute: {
                self.notifyFailure(info: "There might be some connection issue. Please try again!")
            });
            return
        }
        
        user.prepareForURL()
        password.prepareForURL()
        
        //send HTTP POST for login
        let postString = "&warn=true&lt=\(LT)&execution=e1s1&_eventId=submit&submit=LOGIN&username=\(user)&password=\(password)&submit=LOGIN"
        let loginClient = HttpClient(url: "https://login.gatech.edu\(formPost)\(postString)")
        
        guard let response = loginClient.sendGet() else {
            //synchronous network error even though in background thread
            //because the app locks up when calling sync{ } for some reason
            //LoginViewController?.syncronizedNetworkErrorRecieved()
            print("Connection error")
            //notify failure
            DispatchQueue.main.async(execute: {
                self.notifyFailure(info: "There might be some connection issue. Please try again!")
            });
            return
        }
        
        //incorrect password
        if response.contains("Incorrect login or disabled account.") || response.contains("Login requested by:") {
            //didCompletion = true
            //sync() { completion(false, nil) }
            print("Wrong password! Response")
            //notify wrong password
            DispatchQueue.main.async(execute: {
                self.notifyFailure(info: "Your username or password is incorrect!")
            });
            
        } else {
            print("Right password! Send request to GT thrift shop to get userid.")
            //send request to YY and check if its first time user and get userid
            DispatchQueue.main.async(execute: {
                self.loginActivityIndicator.stopAnimating()
                self.uploadUserInfo()
                //self.proceedToMainTabView()
            });
            
        }
    }
    
    func uploadUserInfo() {
        let url = URL(string: "http://ec2-34-196-222-211.compute-1.amazonaws.com/auth/login");
        
        var request = URLRequest(url:url! as URL);
        request.httpMethod = "POST";
        
        let param = [
            "gtusername"  : usernameField.text!
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
            
            
            let responseJSON = try? JSONSerialization.jsonObject(with: data!, options: [])
            if let responseJSON = responseJSON as? [String: Any] {
                print("****** json = \(responseJSON)")
                if let newUser = responseJSON["new"] as? Bool
                {
                    if newUser {
                        if let userId = responseJSON["userId"] {
                            print("user id : \(userId)")
                            self.userIdString = String(userId as! Int)
                            DispatchQueue.main.async(execute: {
                                let ud = UserDefaults.standard
                                ud.set(userId as! Int, forKey: "userId")
                                ud.synchronize()
                                self.proceedToFirstTimeView()
                            });
                        } else {
                            //notify failure
                            DispatchQueue.main.async(execute: {
                                self.notifyFailure(info: "Cannot unwrap userid!")
                            });
                        }
                    } else {
                         if let userId = responseJSON["userId"] {
                            print("user id : \(userId)")
                            DispatchQueue.main.async(execute: {
                                let ud = UserDefaults.standard
                                ud.set(userId as! Int, forKey: "userId")
                                ud.synchronize()
                                self.proceedToMainTabView()
                            });
                        }
                        
                    }
                } else {
                    //notify failure
                    DispatchQueue.main.async(execute: {
                        self.notifyFailure(info: "Cannot unwrap new user flag!")
                    });
                }
            }else {
                //notify failure
                DispatchQueue.main.async(execute: {
                    self.notifyFailure(info: "Cannot unwrap response data!")
                });
            }
            
        }
        
        task.resume()
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
    
    func notifyFailure(info: String) {
        self.sendAlart(info: info)
        self.loginActivityIndicator.stopAnimating()
    }
    
    func proceedToMainTabView() {
        self.performSegue(withIdentifier: "login", sender: self)
    }
    
    func proceedToFirstTimeView() {
        self.performSegue(withIdentifier: "signup", sender: self)
    }
    
    
    @IBAction func unwindToMainPage(_ sender: Any) {
        self.performSegue(withIdentifier: "unwindToMainVC", sender: self)
    }
    
//below are delegate functions
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return true;
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
        
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "signup"{
            let destination = segue.destination as! FirstTimeViewController
            destination.userId = userIdString
        }
        
    }
    
}

extension String {
    
    var length: Int {
        return (self as NSString).length
    }
    
    func asDouble() -> Double? {
        return NumberFormatter().number(from: self)?.doubleValue
    }
    
    func percentStringAsDouble() -> Double? {
        if let displayedNumber = (self as NSString).substring(to: self.length - 1).asDouble() {
            return displayedNumber / 100.0
        }
        return nil
    }
    
    func isWhitespace() -> Bool {
        return self == " " || self == "\n" || self == "\r" || self == "\r\n" || self == "\t"
            || self == "\u{A0}" || self == "\u{2007}" || self == "\u{202F}" || self == "\u{2060}" || self == "\u{FEFF}"
        //there are lots of whitespace characters apparently
        //http://www.fileformat.info/info/unicode/char/00a0/index.htm
    }
    
    mutating func prepareForURL(isFullURL: Bool = false) {
        self = self.preparedForURL(isFullURL: isFullURL)
    }
    
    func preparedForURL(isFullURL: Bool = false) -> String {
        return self.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlPathAllowed) ?? self
    }
    
}

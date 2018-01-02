//
//  LoginViewController.swift
//  GTThriftShop
//
//  Created by Mengyang Shi on 11/29/16.
//  Copyright © 2016 Triple6. All rights reserved.
//

import UIKit
import FirebaseAuth
class LoginViewController: UIViewController, UITextFieldDelegate {
    
    static var authFormPost: String?
    static var authLTPost: String?
    var userIdString = String()
    var effect: UIVisualEffect!
    var loadedDuoTwoFactor = false
    
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var loginActivityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var background: UIImageView!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet var loginBlock: UIView!
    @IBOutlet weak var twoFactorWebView: UIWebView!
    @IBOutlet weak var twoFactorWebViewCenterConstraint: NSLayoutConstraint!
    @IBOutlet weak var loginBlockBlur: UIVisualEffectView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        usernameField.delegate = self
        passwordField.delegate = self
        
        effect = loginBlockBlur.effect
        loginBlockBlur.effect = nil
        
        loginBlock.layer.cornerRadius = 10
        
        loginButton.layer.cornerRadius = 5
        backButton.layer.cornerRadius = 5
        
        self.twoFactorWebViewCenterConstraint.constant = 220
        
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
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
            GlobalHelper.sendAlart(info: "Please fill in all blank fields before login!", VC: self)
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
            
        } else if response.contains("iframe") {
            //need to do two-way auth here
            print("HI IM 2-WAY AUTH")
            self.twoFactorWebView.loadHTMLString(response, baseURL: URL(string: "https://login.gatech.edu/cas/login"))
            self.twoFactorWebView.superview?.alpha = 1.0
            
            self.twoFactorWebView.delegate = TwoFactorWebViewDelegate()
            print("HI IM 2-WAY AUTH 2")
            loadedDuoTwoFactor = false
        }
        else {
            print("Right password! Send request to GT thrift shop to get userid.")
            DispatchQueue.main.async(execute: {
                self.loginActivityIndicator.stopAnimating()
                self.uploadUserInfo()
                //self.proceedToMainTabView()
            });
            
        }
    }
    
    func presentTwoFactorView() {
        print("HI IM 2-WAY AUTH PRESENT")
        
        if self.twoFactorWebViewCenterConstraint.constant == 0 { return }
        
        UIView.animate(withDuration: 0.45, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0.0, options: [], animations: {
            self.twoFactorWebViewCenterConstraint.constant = 0
            self.view.layoutIfNeeded()
        }, completion: nil)
    }
    
    func nextStepAfterTwoWayAuth() {
        print("HI IM 2-WAY AUTH afterwards")
        print("two-way auth success! Send request to GT thrift shop to get userid.")
        DispatchQueue.main.async(execute: {
            self.loginActivityIndicator.stopAnimating()
            self.uploadUserInfo()
        });
    }
    
    func uploadUserInfo() {
        let url = URL(string: "\(GlobalHelper.sharedInstance.AWSUrlHeader)/auth/login");
        
        var request = URLRequest(url:url! as URL);
        request.httpMethod = "POST";
        
        let param = [
            "gtusername"  : usernameField.text!,
            "hash" : GlobalHelper.generateHash(username: usernameField.text!)
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
                                GlobalHelper.storeToUserDefaults(value: userId as! Int, key: "userId")
                                GlobalHelper.storeToUserDefaults(value: responseJSON["token"] as! String, key: "token")
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
                                GlobalHelper.storeToUserDefaults(value: userId as! Int, key: "userId")
                                print(responseJSON["token"] as! String)
                                GlobalHelper.storeToUserDefaults(value: responseJSON["token"] as! String, key: "token")
                                self.proceedToMainTabView(user: userId as! Int)
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
    
    
    func notifyFailure(info: String) {
        GlobalHelper.sendAlart(info: info, VC: self)
        self.loginActivityIndicator.stopAnimating()
    }
    
    func proceedToMainTabView(user: Int) {
        FIRAuth.auth()?.signIn(withEmail: "\(usernameField.text!)@gatech.edu", password: "GTThriftShop_\(user)", completion: { (user, error) in
            if error == nil {
                print(user!.uid)
                
                self.performSegue(withIdentifier: "login", sender: self)
                
            } else {
                print(error!.localizedDescription)
            }
        })
        
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
            destination.gtName = usernameField.text!
        }
        
    }
    
}

//two-way auth related helper
class TwoFactorWebViewDelegate : NSObject, UIWebViewDelegate {
    static var loginController: LoginViewController? {
        return UIApplication.shared.keyWindow?.rootViewController as? LoginViewController
    }
    //URL pointed to by the Duo iframe
    //is loaded by the page at runtime
    func iframeSrc(_ webView: UIWebView) -> String? {
        let content = webView.stringByEvaluatingJavaScript(from: "document.documentElement.outerHTML")
        let iframe = HttpClient.getInfoFromPage((content ?? "") as NSString, infoSearch: "<iframe", terminator: ">")
        return HttpClient.getInfoFromPage((iframe ?? "") as NSString, infoSearch: "src=\"", terminator: "\"")
    }
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        let content = webView.stringByEvaluatingJavaScript(from: "document.documentElement.outerHTML")
        
        //if still waiting on two-factor to complete
        
        if !(TwoFactorWebViewDelegate.loginController?.loadedDuoTwoFactor)! {
            print("HI IM 2-WAY AUTH delegate")
            let isCorrectPage = content?.contains("Two-factor login is needed") == true
            let hasFinishedProcessing = iframeSrc(webView) != nil
            
            if isCorrectPage && hasFinishedProcessing {
                TwoFactorWebViewDelegate.loginController?.loadedDuoTwoFactor = true
                //hide everything but the Duo iframe
                let javascript = "$($('body').append($('#duo_iframe')));" +
                    "$('body > *:not(iframe)').hide();" +
                "$('#duo_iframe').height(100);"
                webView.stringByEvaluatingJavaScript(from: javascript)
                TwoFactorWebViewDelegate.loginController?.presentTwoFactorView()
            }
        }
        
        //successful login
        if let content = content, content.contains("My Workspace") == true || content.contains("Log Out") == true {
            TwoFactorWebViewDelegate.loginController?.nextStepAfterTwoWayAuth()
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

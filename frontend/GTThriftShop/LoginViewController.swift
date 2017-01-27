//
//  LoginViewController.swift
//  GTThriftShop
//
//  Created by Mengyang Shi on 11/29/16.
//  Copyright © 2016 Triple6. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {
    
    static var authFormPost: String?
    static var authLTPost: String?
    
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func login(_ sender: Any) {
        let client = HttpClient(url: "https://login.gatech.edu/cas/login?service=https%3A%2F%2Ft-square.gatech.edu%2Fsakai-login-tool%2Fcontainer")
        guard let loginScreenText = client.sendGet() else {
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
            return
        }
        
        //get LT
        if let previousLT = LoginViewController.authLTPost {
            LT = previousLT
        } else if let LT_part = LT_info {
            LT = "LT" + LT_part
            
            LoginViewController.authLTPost = LT
        } else {
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
            return
        }
        
        //incorrect password
        if response.contains("Incorrect login or disabled account.") || response.contains("Login requested by:") {
            //didCompletion = true
            //sync() { completion(false, nil) }
            print("Wrong password! Response ---> \(response)")
        } else {
            print("Right password! Send request to GT thrift shop to get userid.")
        }
    }
    
    func proceedToSuccessView() {
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let newViewController = storyBoard.instantiateViewController(withIdentifier: "MainTabViewController") as! FirstTimeViewController
        self.navigationController?.pushViewController(newViewController, animated: true)
        
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

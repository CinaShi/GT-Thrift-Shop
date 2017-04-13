//
//  ForgotPasswordViewController.swift
//  GTThriftShop
//
//  Created by Mengyang Shi on 4/13/17.
//  Copyright © 2017 Triple6. All rights reserved.
//

import UIKit

class ForgotPasswordViewController: UIViewController {

    
    @IBOutlet weak var webView: UIWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        webView.loadRequest(URLRequest(url: URL(string: "https://passport.gatech.edu/activation/forgot-password")!))
    }

    
    @IBAction func backAction(_ sender: Any) {
        if webView.canGoBack {
            webView.goBack()
        }
    }
    
    @IBAction func forwardAction(_ sender: Any) {
        if webView.canGoForward {
            webView.goForward()
        }
    }
    
    @IBAction func stopAction(_ sender: Any) {
        webView.stopLoading()
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func refreshAction(_ sender: Any) {
        webView.reload()
    }
    

    
    
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

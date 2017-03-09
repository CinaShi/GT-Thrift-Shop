//
//  ContactSellerViewController.swift
//  GTThriftShop
//
//  Created by Mengyang Shi on 11/29/16.
//  Copyright © 2016 Triple6. All rights reserved.
//

import UIKit

class ContactSellerViewController: UIViewController {
    
    var userId: Int!
    var pid: Int!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        sendInterestInBackground()
    }
    
    func sendInterestInBackground() {
        let url = URL(string: "http://ec2-34-196-222-211.compute-1.amazonaws.com/products/add/interest");
        
        var request = URLRequest(url:url! as URL);
        request.httpMethod = "POST";
        
        let param = [
            "userId"  : userId!,
            "pid"  : pid!
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
                if httpResponse.statusCode == 200{
                    print("interest uplaoded successfully")
                } else {
                    print("some error happened")
                }
            } else {
                print("some error happened")
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
    }
    
    @IBAction func unwindToDetailVC(_ sender: Any) {
        self.performSegue(withIdentifier: "unwindToDetailVC", sender: self)
    }
    
}

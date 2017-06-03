//
//  GlobalHelper.swift
//  GTThriftShop
//
//  Created by Mengyang Shi on 6/3/17.
//  Copyright © 2017 Triple6. All rights reserved.
//

import Foundation
import UIKit

class GlobalHelper {
    static let sharedInstance = GlobalHelper()

    class func sendAlart(info: String, VC: UIViewController) {
        let alertController = UIAlertController(title: "Hey!", message: info, preferredStyle: UIAlertControllerStyle.alert)
        let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default) {
            (result : UIAlertAction) -> Void in
            print("OK")
        }
        alertController.addAction(okAction)
        VC.present(alertController, animated: true, completion: nil)
    }
    
    class func cleanUserDefaults() {
        UserDefaults.standard.removePersistentDomain(forName: Bundle.main.bundleIdentifier!)
        UserDefaults.standard.synchronize()
    }
    
    class func storeToUserDefaults(value: Any, key: String) {
        UserDefaults.standard.set(value, forKey: key)
        UserDefaults.standard.synchronize()
    }
    
}

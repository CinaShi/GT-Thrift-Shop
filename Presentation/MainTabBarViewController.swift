//
//  MainTabBarViewController.swift
//  Edvizer
//
//  Created by chensiding on 16/1/11.
//  Copyright © 2016年 Appfish. All rights reserved.
//

import UIKit

class MainTabBarViewController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let planVC = UIViewController();
        planVC.title = "Plan";
        planVC.tabBarItem.image = UIImage(named: "plan");
        
        let accountVC = UIViewController();
        accountVC.title = "Account";
        accountVC.tabBarItem.image = UIImage(named: "bank");
        
        let alertVC = AlertViewController();
        alertVC.title = "Spending Alert";
        alertVC.tabBarItem.image = UIImage(named: "alert");
        let nav3 = UINavigationController(rootViewController: alertVC)
        
        let analysisVC = UIViewController();
        analysisVC.tabBarItem.title = "Analytics";
        analysisVC.tabBarItem.image = UIImage(named: "analysis");
        
        let settingVC = UIViewController();
        settingVC.title = "Setting";
        settingVC.tabBarItem.image = UIImage(named: "setting");
        
        self.viewControllers = [planVC, accountVC, nav3, analysisVC, settingVC];
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

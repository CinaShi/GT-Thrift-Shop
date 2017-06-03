//
//  RateAndCommentTableViewController.swift
//  GTThriftShop
//
//  Created by Mengyang Shi on 3/9/17.
//  Copyright © 2017 Triple6. All rights reserved.
//

import UIKit

class RateAndCommentTableViewController: UITableViewController, UITextViewDelegate, UITextFieldDelegate {
    
    var rating = 1
    var comment: String!
    var userId: Int!
    var targetId: Int!
    var tranId: Int!
    
    
    @IBOutlet weak var commentTextView: UITextView!
    @IBOutlet var mainTable: UITableView!
    @IBOutlet var stars: [UIButton]!
    //@IBOutlet weak var submitButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.extraLight)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = mainTable.bounds
        let backImageView = UIImageView(image: UIImage(named: "iOS-9-Wallpaper"))
        backImageView.addSubview(blurEffectView)
        mainTable.backgroundView = backImageView
        
        self.mainTable.separatorStyle = UITableViewCellSeparatorStyle.none
        
        
        commentTextView.delegate = self
        self.navigationController?.navigationBar.isHidden = false
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.tap(gesture:)))
        self.view.addGestureRecognizer(tapGesture)
        
        let color1 = UIColor(red: 189/255, green: 195/255, blue: 199/255, alpha: 1)
        commentTextView.layer.cornerRadius = 10
        commentTextView.layer.borderColor = color1.cgColor
        commentTextView.layer.borderWidth = 1
        
//        let color2 = UIColor(red: 0/255, green: 128/255, blue: 255/255, alpha: 1)
//        submitButton.layer.cornerRadius = 20
//        submitButton.layer.borderColor = color2.cgColor
//        submitButton.layer.borderWidth = 1
        
        commentTextView.text = "Type your comment here."
        commentTextView.textColor = UIColor.lightGray
        
    }

    
    @IBAction func unwindToDetailVC(_ sender: Any) {
        self.performSegue(withIdentifier: "unwindFromRateAndCommentVC", sender: self)
    }
    
    @IBAction func submitRateAndComment(_ sender: Any) {
        if commentTextView.text! == "" {
            GlobalHelper.sendAlart(info: "Please write down your comments before submission!", VC: self)
        } else {
            //ready to submit
            //submitButton.isEnabled = false
            uploadComment()
        }
    }
//    @IBAction func submitRateAndComment(_ sender: Any) {
//        if commentTextView.text! == "" {
//            sendAlert(info: "Please write down your comments before submission!")
//        } else {
//            //ready to submit
//            submitButton.isEnabled = false
//            uploadComment()
//        }
//    }
    
    func uploadComment() {
        let url = URL(string: "http://ec2-34-196-222-211.compute-1.amazonaws.com/user/cr/update")
        
        var request = URLRequest(url:url! as URL)
        request.httpMethod = "POST"
        
        
        let param = [
            "userId"  : targetId!,
            "rate"    : rating,
            "ccontent"    : commentTextView.text!,
            "commentatorId"    : userId!,
            "tranId"    : tranId!,
            ] as [String : Any]
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
                if httpResponse.statusCode == 200 {
                    
                    print("comment successfully submitted")
                    DispatchQueue.main.async(execute: {
                        self.dismiss(animated: true, completion: nil)
                        self.performSegue(withIdentifier: "unwindFromRateAndCommentVC", sender: self)
                    });
                }else if httpResponse.statusCode == 404 {
                    DispatchQueue.main.async(execute: {
                        self.notifyFailure(info: "Cannot find URL!")
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
        GlobalHelper.sendAlart(info: info, VC: self)
        //submitButton.isEnabled = true
    }
    
    
    // MARK: - rating-related function goes here
    
    @IBAction func rateOneStar(_ sender: Any) {
        rating = 1
        stars[0].setBackgroundImage(#imageLiteral(resourceName: "Rating Filled-100"), for: .normal)
        stars[1].setBackgroundImage(#imageLiteral(resourceName: "Rating-100"), for: .normal)
        stars[2].setBackgroundImage(#imageLiteral(resourceName: "Rating-100"), for: .normal)
        stars[3].setBackgroundImage(#imageLiteral(resourceName: "Rating-100"), for: .normal)
        stars[4].setBackgroundImage(#imageLiteral(resourceName: "Rating-100"), for: .normal)
    }
    
    @IBAction func rateTwoStar(_ sender: Any) {
        rating = 2
        stars[0].setBackgroundImage(#imageLiteral(resourceName: "Rating Filled-100"), for: .normal)
        stars[1].setBackgroundImage(#imageLiteral(resourceName: "Rating Filled-100"), for: .normal)
        stars[2].setBackgroundImage(#imageLiteral(resourceName: "Rating-100"), for: .normal)
        stars[3].setBackgroundImage(#imageLiteral(resourceName: "Rating-100"), for: .normal)
        stars[4].setBackgroundImage(#imageLiteral(resourceName: "Rating-100"), for: .normal)
    }
    
    @IBAction func rateThreeStar(_ sender: Any) {
        rating = 3
        stars[0].setBackgroundImage(#imageLiteral(resourceName: "Rating Filled-100"), for: .normal)
        stars[1].setBackgroundImage(#imageLiteral(resourceName: "Rating Filled-100"), for: .normal)
        stars[2].setBackgroundImage(#imageLiteral(resourceName: "Rating Filled-100"), for: .normal)
        stars[3].setBackgroundImage(#imageLiteral(resourceName: "Rating-100"), for: .normal)
        stars[4].setBackgroundImage(#imageLiteral(resourceName: "Rating-100"), for: .normal)
    }
    
    @IBAction func rateFourStar(_ sender: Any) {
        rating = 4
        stars[0].setBackgroundImage(#imageLiteral(resourceName: "Rating Filled-100"), for: .normal)
        stars[1].setBackgroundImage(#imageLiteral(resourceName: "Rating Filled-100"), for: .normal)
        stars[2].setBackgroundImage(#imageLiteral(resourceName: "Rating Filled-100"), for: .normal)
        stars[3].setBackgroundImage(#imageLiteral(resourceName: "Rating Filled-100"), for: .normal)
        stars[4].setBackgroundImage(#imageLiteral(resourceName: "Rating-100"), for: .normal)
    }
    
    @IBAction func rateFiveStar(_ sender: Any) {
        rating = 5
        stars[0].setBackgroundImage(#imageLiteral(resourceName: "Rating Filled-100"), for: .normal)
        stars[1].setBackgroundImage(#imageLiteral(resourceName: "Rating Filled-100"), for: .normal)
        stars[2].setBackgroundImage(#imageLiteral(resourceName: "Rating Filled-100"), for: .normal)
        stars[3].setBackgroundImage(#imageLiteral(resourceName: "Rating Filled-100"), for: .normal)
        stars[4].setBackgroundImage(#imageLiteral(resourceName: "Rating Filled-100"), for: .normal)
    }
    
    // MARK: - textView delegate
    func textView(_ textView: UITextView, shouldChangeTextIn shouldChangeTextInRange: NSRange, replacementText: String) -> Bool {
        if(replacementText.isEqual("\n")) {
            commentTextView.resignFirstResponder()
            return false
        }
        return true
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if commentTextView.textColor == UIColor.lightGray {
            commentTextView.text = nil
            commentTextView.textColor = UIColor.black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if commentTextView.text.isEmpty {
            commentTextView.text = "Type your comment here."
            commentTextView.textColor = UIColor.lightGray
        }
    }
    
    func tap(gesture: UITapGestureRecognizer) {
        commentTextView.resignFirstResponder()
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "unwindFromRateAndCommentVC" {
            let destination = segue.destination as! ItemDetailViewController
            destination.isRated = true
        }
        
    }
    
    

}

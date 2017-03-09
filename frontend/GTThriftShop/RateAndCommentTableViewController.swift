//
//  RateAndCommentTableViewController.swift
//  GTThriftShop
//
//  Created by Mengyang Shi on 3/9/17.
//  Copyright © 2017 Triple6. All rights reserved.
//

import UIKit

class RateAndCommentTableViewController: UITableViewController, UITextViewDelegate {
    
    var rating = 1
    
    @IBOutlet weak var commentTextView: UITextView!
    
    @IBOutlet var stars: [UIButton]!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        commentTextView.delegate = self
        self.navigationController?.navigationBar.isHidden = false
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.tap(gesture:)))
        self.view.addGestureRecognizer(tapGesture)
    }

    
    @IBAction func unwindToDetailVC(_ sender: Any) {
        self.performSegue(withIdentifier: "unwindFromRateAndCommentVC", sender: self)
    }
    
    @IBAction func submitRateAndComment(_ sender: Any) {
        
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
    
    func tap(gesture: UITapGestureRecognizer) {
        commentTextView.resignFirstResponder()
    }

}

//
//  SellTableViewController.swift
//  GTThriftShop
//
//  Created by Mengyang Shi on 3/9/17.
//  Copyright © 2017 Triple6. All rights reserved.
//

import UIKit

class SellTableViewController: UITableViewController, UIImagePickerControllerDelegate,  UINavigationControllerDelegate, UIPickerViewDelegate {
    
    //
    let categories = ["羊羊大姐","梦哥","小弈辰","文胸👙","nigga"]
    
    
    @IBOutlet weak var itemImageView: UIImageView!
    @IBOutlet weak var itemNameField: UITextField!
    @IBOutlet weak var usedYearField: UITextField!
    @IBOutlet weak var priceField: UITextField!
    @IBOutlet weak var categoryField: UITextField!
    @IBOutlet weak var descriptionTextView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        
        //picker view
        let pickerView = UIPickerView()
        pickerView.delegate = self
        categoryField.inputView = pickerView

        
    }

    @IBAction func addPhoto(_ sender: AnyObject) {
        let imagePicker:UIImagePickerController = UIImagePickerController()
        imagePicker.sourceType = UIImagePickerControllerSourceType.photoLibrary
        imagePicker.delegate = self
        
        self.present(imagePicker, animated: true, completion: nil)
        
    }
    
    @IBAction func submit(_ sender: AnyObject) {
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let pickedImage:UIImage = info[UIImagePickerControllerOriginalImage] as! UIImage
        
        //scale down image
        let scaledImage = self.scaleImageWith(pickedImage, and: CGSize(width: 240, height: 240))
        itemImageView.image = scaledImage
        
        picker.dismiss(animated: true, completion: nil)
    }
    
    func scaleImageWith(_ image:UIImage, and newSize:CGSize)->UIImage{
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0)
        image.draw(in: CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height))
        let newImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        return newImage
    }
    
    //delegates
    func numberOfComponetsInPickerView(_ pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return categories.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return categories[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.categoryField.text = categories[row]
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

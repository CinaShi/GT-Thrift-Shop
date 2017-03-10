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
    var categories = [String]()
    var selectedAddPhotoImageView: UIImageView?
    
    @IBOutlet var photosImageViews: [UIImageView]!
    
    @IBOutlet var addPhotoButtons: [UIButton]!
    
    @IBOutlet weak var itemNameField: UITextField!
    @IBOutlet weak var usedYearField: UITextField!
    @IBOutlet weak var priceField: UITextField!
    @IBOutlet weak var categoryField: UITextField!
    @IBOutlet weak var descriptionTextView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        loadTagsFromLocal()
        
        //picker view
        let pickerView = UIPickerView()
        pickerView.delegate = self
        categoryField.inputView = pickerView
        
        for button in addPhotoButtons {
            self.view.bringSubview(toFront: button)
        }
    }
    
    func loadTagsFromLocal() {
        if let tags = UserDefaults.standard.array(forKey: "tags") {
            for tag in tags {
                let category = tag as! String
                categories.append(category)
            }
        }
    }

    @IBAction func addPhoto(_ sender: AnyObject) {
        print("hi!")
        for (index, button) in addPhotoButtons.enumerated() {
            if sender as! UIButton == button {
                selectedAddPhotoImageView = photosImageViews[index]
                let imagePicker:UIImagePickerController = UIImagePickerController()
                imagePicker.sourceType = UIImagePickerControllerSourceType.photoLibrary
                imagePicker.delegate = self
                
                self.present(imagePicker, animated: true, completion: nil)
                break
            }
            
        }
        
        
    }
    
    @IBAction func submit(_ sender: AnyObject) {
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let pickedImage:UIImage = info[UIImagePickerControllerOriginalImage] as! UIImage
        
        //scale down image
        let imageSize = pickedImage.size
        let imageViewSideLength = Float((selectedAddPhotoImageView?.frame.size.width)!)
        print(imageViewSideLength)
        let scaledImage: UIImage!
        if Float(imageSize.width) >= Float(imageSize.height) {
            let scaledHeight = imageViewSideLength * Float(imageSize.height) / Float(imageSize.width)
            print("height -> \(scaledHeight)")
            scaledImage = self.scaleImageWith(pickedImage, and: CGSize(width: Int(imageViewSideLength), height: Int(scaledHeight)))
            selectedAddPhotoImageView?.image = scaledImage
        } else {
            let scaledWidth = imageViewSideLength * Float(imageSize.width) / Float(imageSize.height)
            print("width -> \(scaledWidth)")
            scaledImage = self.scaleImageWith(pickedImage, and: CGSize(width: Int(scaledWidth), height: Int(imageViewSideLength)))
            selectedAddPhotoImageView?.image = scaledImage
        }
        
        
        
        
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

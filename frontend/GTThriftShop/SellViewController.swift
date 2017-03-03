//
//  SellViewController.swift
//  GTThriftShop
//
//  Created by Mengyang Shi on 11/29/16.
//  Copyright © 2016 Triple6. All rights reserved.
//

import UIKit

class SellViewController: UIViewController, UIImagePickerControllerDelegate,  UINavigationControllerDelegate {
    
    @IBOutlet weak var itemImageView: UIImageView!
    @IBOutlet weak var itemNameField: UITextField!
    @IBOutlet weak var usedYearField: UITextField!
    @IBOutlet weak var priceField: UITextField!
    @IBOutlet weak var tagField: UITextField!
    @IBOutlet weak var descriptionTextView: UITextView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func addPhoto(_ sender: AnyObject) {
        let imagePicker:UIImagePickerController = UIImagePickerController()
        imagePicker.sourceType = UIImagePickerControllerSourceType.photoLibrary
        imagePicker.delegate = self
        
        self.present(imagePicker, animated: true, completion: nil)

    }
    
    @IBAction func submit(_ sender: AnyObject) {
        let defaults = UserDefaults.standard
        
        defaults.set(itemNameField.text, forKey: "newItemName")
        defaults.set("\(usedYearField.text!) years", forKey: "newItemUsedYear")
        defaults.set("$\(priceField.text!)", forKey: "newItemPrice")
        defaults.set(tagField.text, forKey: "newItemTag")
        defaults.set(descriptionTextView.text, forKey: "newItemDescription")
        defaults.set("Mengyang Shi", forKey: "newItemOwner")
        defaults.set(UIImagePNGRepresentation(itemImageView.image!), forKey: "newItemImage")
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
    
}

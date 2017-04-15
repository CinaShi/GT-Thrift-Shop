//
//  SellTableViewController.swift
//  GTThriftShop
//
//  Created by Mengyang Shi on 3/9/17.
//  Copyright © 2017 Triple6. All rights reserved.
//

import UIKit

class SellTableViewController: UITableViewController, UIImagePickerControllerDelegate,  UINavigationControllerDelegate, UIPickerViewDelegate, UITextFieldDelegate, UITextViewDelegate {
    
    //
    var categories = [String]()
    var selectedAddPhotoImageView: UIImageView?
    var photos = [UIImage?](repeating: nil, count:6)
    var selectedIndex: Int!
    var userId: Int!
    var assignedPid = -1
    
    @IBOutlet var photosImageViews: [UIImageView]!
    
    @IBOutlet var addPhotoButtons: [UIButton]!
    
    @IBOutlet weak var itemNameField: UITextField!
    @IBOutlet weak var usedYearField: UITextField!
    @IBOutlet weak var priceField: UITextField!
    @IBOutlet weak var categoryField: UITextField!
    @IBOutlet weak var descriptionTextView: UITextView!
    
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var resetButton: UIButton!
    
    @IBOutlet var mainTable: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.extraLight)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = mainTable.bounds
        //blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        let backImageView = UIImageView(image: UIImage(named: "iOS-9-Wallpaper"))
        backImageView.addSubview(blurEffectView)
        mainTable.backgroundView = backImageView
        
        loadTagsFromLocal()
        userId = UserDefaults.standard.integer(forKey: "userId")
        //picker view
        let pickerView = UIPickerView()
        pickerView.delegate = self
        categoryField.inputView = pickerView
        //buttons
        let color1 = UIColor(colorLiteralRed: 0, green: 128/255, blue:1, alpha: 1)
        self.submitButton.layer.borderWidth = 1
        self.resetButton.layer.borderWidth = 1
        self.submitButton.layer.cornerRadius = 15
        self.resetButton.layer.cornerRadius = 15
        self.submitButton.layer.borderColor = color1.cgColor
        self.resetButton.layer.borderColor = color1.cgColor
        

        
        for button in addPhotoButtons {
            self.view.bringSubview(toFront: button)
        }
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.tap(gesture:)))
        self.view.addGestureRecognizer(tapGesture)
        
        descriptionTextView.text = "Type your description here."
        descriptionTextView.textColor = UIColor.lightGray
    }
    
    
    func loadTagsFromLocal() {
        if let tags = UserDefaults.standard.array(forKey: "tags") {
            for tag in tags {
                let category = tag as! String
                if category != "All" {
                    categories.append(category)
                }
            }
        }
    }

    @IBAction func addPhoto(_ sender: AnyObject) {
        print("hi!")
        let alert = UIAlertController(title: nil, message: "Choose a way", preferredStyle: .actionSheet)
        let cameraAction = UIAlertAction(title: "Take a photo", style: .default) { action in
            for (index, button) in self.addPhotoButtons.enumerated() {
                if sender as! UIButton == button {
                    self.selectedAddPhotoImageView = self.photosImageViews[index]
                    self.selectedIndex = index
                    let imagePicker:UIImagePickerController = UIImagePickerController()
                    imagePicker.sourceType = UIImagePickerControllerSourceType.camera
                    
                    imagePicker.delegate = self
                    
                    self.present(imagePicker, animated: true, completion: nil)
                    break
                }
                
            }

        }
        let libraryAction = UIAlertAction(title: "Choose from library", style: .default) { action in
            for (index, button) in self.addPhotoButtons.enumerated() {
                if sender as! UIButton == button {
                    self.selectedAddPhotoImageView = self.photosImageViews[index]
                    self.selectedIndex = index
                    let imagePicker:UIImagePickerController = UIImagePickerController()
                    imagePicker.sourceType = UIImagePickerControllerSourceType.photoLibrary
                    imagePicker.delegate = self
                    
                    self.present(imagePicker, animated: true, completion: nil)
                    break
                }
                
            }
            
        }

        alert.addAction(cameraAction)
        alert.addAction(libraryAction)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))

        self.present(alert, animated: true, completion: nil)
        
    }
   
    @IBAction func submit(_ sender: AnyObject) {
        if itemNameField.text! == "" || priceField.text! == "" || usedYearField.text! == "" || descriptionTextView.text! == "" || categoryField.text! == "" {
            sendAlart(info: "Please fill in all information before submit!")
        } else {
            var photosToUpload = [UIImage]()
            for photo in photos {
                if photo != nil {
                    photosToUpload.append(photo!)
                }
            }
            if photosToUpload.count <= 0 {
                self.sendAlart(info: "Please choose at least 1 photo!")
            } else {
                submitButton.isEnabled = false
                uploadInfoFirst()
            }
            
        }
        
    }
    
    func uploadInfoFirst() {
        let url = URL(string: "http://ec2-34-196-222-211.compute-1.amazonaws.com/products/add/allInfo")
        
        var request = URLRequest(url:url! as URL)
        request.httpMethod = "POST"
        
        
        let param = [
            "userId"  : userId!,
            "pName"    : itemNameField.text!,
            "pPrice"    : priceField.text!,
            "pInfo"    : descriptionTextView.text!,
            "usedTime"    : usedYearField.text!,
            "tag"   : categoryField.text!
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
                    do {
                        let json = try JSONSerialization.jsonObject(with: data!, options: []) as! Dictionary<String, Any>
                        self.assignedPid = json["pid"] as! Int
                        
                    } catch let error as NSError {
                        print("Failed to load: \(error.localizedDescription)")
                    }
                    
                    DispatchQueue.main.async(execute: {
                        self.uploadPhotos()
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
    
    func uploadPhotos() {
        print("assigned pid ---> \(assignedPid)")
        if assignedPid < 0 {
            self.notifyFailure(info: "Unable to upload info to server!")
            return
        }
        var photosToUpload = [UIImage]()
        for photo in photos {
            if photo != nil {
                photosToUpload.append(photo!)
            }
        }
        
        let url:URL = URL(string: "http://ec2-34-196-222-211.compute-1.amazonaws.com/products/add/images/\(assignedPid)")!
        let session = URLSession.shared
        
        let request = NSMutableURLRequest(url:url)
        request.httpMethod = "POST"
        
        
        let boundary: NSString = "----CustomFormBoundarycC4YiaUFwM44F6rT"
        let body: NSMutableData = NSMutableData()
        
        // you can also send multiple images
        if photosToUpload.count > 0 {
            for i in (0..<photosToUpload.count) {
                body.append(("--\(boundary)\r\n" as String).data(using: String.Encoding.utf8, allowLossyConversion: true)!)
                body.append("Content-Disposition: form-data; name=\"files\"; filename=\"photo\(i+1).jpeg\"\r\n" .data(using: String.Encoding.utf8, allowLossyConversion: true)!)
                body.append("Content-Type: image/jpeg\r\n\r\n".data(using: String.Encoding.utf8, allowLossyConversion: true)!)
                
                // change quality of image here
                body.append(UIImageJPEGRepresentation(photosToUpload[i], 0.5)!)
                body.append("\r\n".data(using: String.Encoding.utf8, allowLossyConversion: true)!)
            }
        }
        
        body.append("--\(boundary)--\r\n".data(using: String.Encoding.utf8, allowLossyConversion: true)!)
        
        request.httpBody = body as Data
        request.timeoutInterval = 20
        request.addValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        let task = session.dataTask(with: request as URLRequest) {
            (
            data, response, error) in
            
            guard let data = data, let _:URLResponse = response  , error == nil else {
                print("******* error=\(error)")
                DispatchQueue.main.async(execute: {
                    self.notifyFailure(info: "There might be some connection issue. Please try again!")
                });
                
                return
            }
            print("******* response = \(response!)")
            
            // Print out reponse body
            let responseString = NSString(data: data, encoding: String.Encoding.utf8.rawValue)
            print("****** response data = \(responseString!)")
            if let httpResponse = response as? HTTPURLResponse {
                print("***** statusCode: \(httpResponse.statusCode)")
                if httpResponse.statusCode == 200 {
                    print("upload success")
                    DispatchQueue.main.async(execute: {
                        self.performSegue(withIdentifier: "uploadInfoSuccess", sender: self)
                    });
                } else if httpResponse.statusCode == 404 {
                    DispatchQueue.main.async(execute: {
                        self.notifyFailure(info: "Cannot find url!")
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
    
    @IBAction func resetAll(_ sender: Any) {
        itemNameField.text = ""
        usedYearField.text = ""
        priceField.text = ""
        categoryField.text = ""
        descriptionTextView.text = ""
        
        for imageView in photosImageViews {
            imageView.image = #imageLiteral(resourceName: "Unchecked Checkbox-100")
        }
        photos = [UIImage?](repeating: nil, count:6)
    }
    
    
    
    func notifyFailure(info: String) {
        self.sendAlart(info: info)
        submitButton.isEnabled = true
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
    
    
    //imagePicker delegate
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let pickedImage:UIImage = info[UIImagePickerControllerOriginalImage] as! UIImage
        
        photos[selectedIndex] = pickedImage
        //scale down image
        let imageSize = pickedImage.size
        let imageViewSideLength = Float((selectedAddPhotoImageView?.frame.size.width)!)
//        print(imageViewSideLength)
        let scaledImage: UIImage!
        if Float(imageSize.width) >= Float(imageSize.height) {
            let scaledHeight = imageViewSideLength * Float(imageSize.height) / Float(imageSize.width)
//            print("height -> \(scaledHeight)")
            scaledImage = self.scaleImageWith(pickedImage, and: CGSize(width: Int(imageViewSideLength), height: Int(scaledHeight)))
            selectedAddPhotoImageView?.image = scaledImage
        } else {
            let scaledWidth = imageViewSideLength * Float(imageSize.width) / Float(imageSize.height)
//            print("width -> \(scaledWidth)")
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
    
    // text delegates
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return true;
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn shouldChangeTextInRange: NSRange, replacementText: String) -> Bool {
        if(replacementText.isEqual("\n")) {
            descriptionTextView.resignFirstResponder()
            return false
        }
        return true
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if descriptionTextView.textColor == UIColor.lightGray {
            descriptionTextView.text = nil
            descriptionTextView.textColor = UIColor.black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if descriptionTextView.text.isEmpty {
            descriptionTextView.text = "Type your description here."
            descriptionTextView.textColor = UIColor.lightGray
        }
    }
    
    func tap(gesture: UITapGestureRecognizer) {
        self.view.endEditing(true)
        descriptionTextView.resignFirstResponder()
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

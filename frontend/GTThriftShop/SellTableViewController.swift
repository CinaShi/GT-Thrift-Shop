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
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        loadTagsFromLocal()
        userId = UserDefaults.standard.integer(forKey: "userId")
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
                if category != "All" {
                    categories.append(category)
                }
            }
        }
    }

    @IBAction func addPhoto(_ sender: AnyObject) {
        print("hi!")
        for (index, button) in addPhotoButtons.enumerated() {
            if sender as! UIButton == button {
                selectedAddPhotoImageView = photosImageViews[index]
                selectedIndex = index
                let imagePicker:UIImagePickerController = UIImagePickerController()
                imagePicker.sourceType = UIImagePickerControllerSourceType.photoLibrary
                imagePicker.delegate = self
                
                self.present(imagePicker, animated: true, completion: nil)
                break
            }
            
        }
        
        
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
        let url = URL(string: "http://ec2-34-196-222-211.compute-1.amazonaws.com/add/allInfo")
        
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
                        self.notifyFailure(info: "User already exists! Please login again!")
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
        
        
        
        let boundary = generateBoundaryString()
        
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        var imagesData = [Data]()
        for photo in photosToUpload {
            imagesData.append(UIImageJPEGRepresentation(photo, 1)!)
        }
        
        if(imagesData.count == 0)  { return }
        
        request.httpBody = createBodyWithParameters(parameters: nil, filePathKey: "file", imagesDataKey: imagesData as [NSData], boundary: boundary) as Data
        
        
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
                        self.notifyFailure(info: "User already exists! Please login again!")
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
    
    func createBodyWithParameters(parameters: [String: String]?, filePathKey: String?, imagesDataKey: [NSData]?, boundary: String) -> NSData {
        let body = NSMutableData();
        
        if parameters != nil {
            for (key, value) in parameters! {
                body.appendString(string: "--\(boundary)\r\n")
                body.appendString(string: "Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n")
                body.appendString(string: "\(value)\r\n")
            }
        }
        
        if imagesDataKey != nil {
            var imageCounter = 1
            for imageDataKey in imagesDataKey! {
                let filename = "\(imageCounter).jpg"
                let mimetype = "image/jpg"
                
                
                body.appendString(string: "--\(boundary)\r\n")
                body.appendString(string: "Content-Disposition: form-data; name=\"\(filePathKey!)\"; filename=\"\(filename)\"\r\n")
                body.appendString(string: "Content-Type: \(mimetype)\r\n\r\n")
                body.append(imageDataKey as Data)
                body.appendString(string: "\r\n")
                imageCounter += 1
            }
            
        }
        
        
        body.appendString(string: "--\(boundary)--\r\n")
        
        return body
    }
    
    func generateBoundaryString() -> String {
        return "Boundary-\(NSUUID().uuidString)"
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
    
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

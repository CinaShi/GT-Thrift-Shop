//
//  FirstTimeViewController.swift
//  GTThriftShop
//
//  Created by Mengyang Shi on 1/26/17.
//  Copyright © 2017 Triple6. All rights reserved.
//

import UIKit
import FirebaseAuth
import Alamofire

class FirstTimeViewController: UIViewController, UITextViewDelegate, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var nickNameField: UITextField!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var descriptionView: UITextView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var submitActivityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var uploadPhotoButton: UIButton!
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var background: UIImageView!
    
    var userId = String()
    var gtName = String()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        descriptionView.delegate = self
        nickNameField.delegate = self
        emailField.delegate = self
        
        print("****** userID ---> \(userId)")
        
        self.navigationController?.navigationBar.isHidden = true
        
        descriptionView.text = "Introduce yourself:"
        descriptionView.textColor = UIColor.lightGray
        
        imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleSelectProfileImageView)))
        imageView.isUserInteractionEnabled = true
        
        submitButton.layer.borderWidth = 1
        submitButton.layer.borderColor = UIColor(red: 0, green: 128/255, blue: 1, alpha: 1).cgColor
        submitButton.layer.cornerRadius = 20
        
        let blurEffect = UIBlurEffect(style: .light)
        let blurView = UIVisualEffectView(effect: blurEffect)
        let width = UIScreen.main.bounds.size.width
        let height = UIScreen.main.bounds.size.height
        
        blurView.frame.size = CGSize(width: width, height: height)
        blurView.alpha = 0.9
        background.addSubview(blurView)
        imageView.layer.cornerRadius = imageView.frame.width/2
        imageView.clipsToBounds = true
        
    }
    
    //all button functions start here
    
    @IBAction func uploadImage(_ sender: AnyObject) {
        handleSelectProfileImageView()
    }
    
    @IBAction func submitInfo(_ sender: AnyObject) {
        if nickNameField.text! == "" || emailField.text! == "" || descriptionView.text! == "" {
            GlobalHelper.sendAlart(info: "Please fill in all blank fields before submit!", VC: self)
        } else {
            self.uploadPhotoButton.isEnabled = false
            self.submitButton.isEnabled = false
            self.submitPhotoFirst()
        }
        
    }
    
    
    //all helper methods start here
    
    func handleSelectProfileImageView() {
//        let picker = UIImagePickerController()
//        
//        picker.delegate = self
//        picker.allowsEditing = true
//        picker.sourceType = .photoLibrary
//        if UIImagePickerController.isSourceTypeAvailable(.camera) {
//            picker.sourceType = UIImagePickerControllerSourceType.camera
//            picker.cameraCaptureMode = .photo
//            picker.modalPresentationStyle = .fullScreen
//            present(picker,animated: true,completion: nil)
//        } else {
//            print("no camera, use library instead")
//            picker.mediaTypes = UIImagePickerController.availableMediaTypes(for: .photoLibrary)!
//            present(picker, animated: true, completion: nil)
//        }
    
        let alert = UIAlertController(title: nil, message: "Choose a way", preferredStyle: .actionSheet)
        let cameraAction = UIAlertAction(title: "Take a photo", style: .default) { action in
            let imagePicker:UIImagePickerController = UIImagePickerController()
            imagePicker.sourceType = UIImagePickerControllerSourceType.camera
            imagePicker.delegate = self
            self.present(imagePicker, animated: true, completion: nil)
        }
        let libraryAction = UIAlertAction(title: "Choose from library", style: .default) { action in
            let imagePicker:UIImagePickerController = UIImagePickerController()
            imagePicker.sourceType = UIImagePickerControllerSourceType.photoLibrary
            imagePicker.delegate = self
            self.present(imagePicker, animated: true, completion: nil)
        }
        
        alert.addAction(cameraAction)
        alert.addAction(libraryAction)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        self.present(alert, animated: true, completion: nil)

    }
    
//    func createBodyWithParameters(parameters: [String: String]?, filePathKey: String?, imageDataKey: NSData?, boundary: String) -> NSData {
//        let body = NSMutableData();
//        
//        if parameters != nil {
//            for (key, value) in parameters! {
//                body.appendString(string: "--\(boundary)\r\n")
//                body.appendString(string: "Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n")
//                body.appendString(string: "\(value)\r\n")
//            }
//        }
//        
//        if imageDataKey != nil {
//            let filename = "\(self.userId)-avatar.jpg"
//            let mimetype = "image/jpg"
//            
//            
//            body.appendString(string: "--\(boundary)\r\n")
//            body.appendString(string: "Content-Disposition: form-data; name=\"\(filePathKey!)\"; filename=\"\(filename)\"\r\n")
//            body.appendString(string: "Content-Type: \(mimetype)\r\n\r\n")
//            body.append(imageDataKey as! Data)
//            body.appendString(string: "\r\n")
//        }
//        
//        
//        body.appendString(string: "--\(boundary)--\r\n")
//        
//        return body
//    }
//    
//    func generateBoundaryString() -> String {
//        return "Boundary-\(NSUUID().uuidString)"
//    }
    
    
    func submitPhotoFirst() {
        let url:URL = URL(string: "\(GlobalHelper.sharedInstance.AWSUrlHeader)/user/image")!
        
        
        let imageData = UIImageJPEGRepresentation(imageView.image!, 1)
        
        if(imageData==nil)  { return; }
        
        let param: [String: String] = [
            "userId"  : UserDefaults.standard.string(forKey: "userId")!,
            "token" : UserDefaults.standard.string(forKey: "token")!
        ]
        
        submitActivityIndicator.startAnimating()
        
        Alamofire.upload(multipartFormData: { multipartFormData in
            
            let jsonData = try? JSONSerialization.data(withJSONObject: param)
            multipartFormData.append(jsonData!, withName: "json")
            
            multipartFormData.append(imageData!, withName: "file", fileName: "\(self.userId)-avatar.jpeg", mimeType: "image/jpeg")
            
            
            //            for (key, value) in param {
            //                multipartFormData.append((value.data(using: .utf8))!, withName: key)
            //            }
        }, to: url, method: .post, headers: nil,
           encodingCompletion: { encodingResult in
            switch encodingResult {
            case .success(let upload, _, _):
                upload.response { [weak self] response in
                    guard self != nil else {
                        return
                    }
                    if let httpResponse = response.response {
                        print("***** statusCode: \(httpResponse.statusCode)")
                        if httpResponse.statusCode == 200 {
                            print("upload success")
                            let imageUrl =  String(data: response.data!, encoding: String.Encoding.utf8)
                            print("******* image url = \(imageUrl!)")
                            self?.uploadWholeInfo(imageurl: imageUrl!)
                        } else if httpResponse.statusCode == 404 {
                            DispatchQueue.main.async(execute: {
                                self?.notifyFailure(info: "Cannot find url!")
                            });
                        }
                        else {
                            DispatchQueue.main.async(execute: {
                                print(response)
                                self?.notifyFailure(info: "There might be some connection issue. Please try again!")
                            });
                            
                        }
                    } else {
                        DispatchQueue.main.async(execute: {
                            self?.notifyFailure(info: "There might be some connection issue. Please try again!")
                        });
                    }
                }
            case .failure(let encodingError):
                print("error:\(encodingError)")
                self.notifyFailure(info: "There might be some connection issue. Please try again!")
            }
        })
        
    }
    
    func uploadWholeInfo(imageurl: String) {
        let url = URL(string: "\(GlobalHelper.sharedInstance.AWSUrlHeader)/user/info");
        
        var request = URLRequest(url:url! as URL);
        request.httpMethod = "POST";
        
        let param = [
            "userId"  : userId,
            "nickname"    : nickNameField.text!,
            "email"    : emailField.text!,
            "avatarURL"    : imageurl,
            "description"    : descriptionView.text!,
            "token" : UserDefaults.standard.string(forKey: "token")!
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
                if httpResponse.statusCode == 200 {
                    
                    DispatchQueue.main.async(execute: {
                        self.submitActivityIndicator.stopAnimating()
                        self.proceedToSuccessView()
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
    
    func notifyFailure(info: String) {
        GlobalHelper.sendAlart(info: info, VC: self)
        self.uploadPhotoButton.isEnabled = true
        self.submitButton.isEnabled = true
        self.submitActivityIndicator.stopAnimating()
    }
    
    func proceedToSuccessView() {
        FIRAuth.auth()?.createUser(withEmail: "\(gtName)@gatech.edu", password: "GTThriftShop_\(userId)", completion: { (user, error) in
            if error == nil {
                print(user!.uid)
                
                self.performSegue(withIdentifier: "signupSuccess", sender: self)
            } else {
                print(error!.localizedDescription)
            }
        })
        
    }
    
    //all delegates start here
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.lightGray {
            textView.text = nil
            textView.textColor = UIColor.black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "Introduce yourself:"
            textView.textColor = UIColor.lightGray
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            self.view.endEditing(true)
            return false
        } else {
            return true
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return true;
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let chosenImage = info[UIImagePickerControllerOriginalImage] as! UIImage
        imageView.contentMode = .scaleAspectFit
        imageView.image = chosenImage
        dismiss(animated:true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
}

extension NSMutableData {
    
    func appendString(string: String) {
        let data = string.data(using: String.Encoding.utf8, allowLossyConversion: true)
        append(data!)
    }
}



//
//  ContactSellerViewController.swift
//  GTThriftShop
//
//  Created by Mengyang Shi on 3/31/17.
//  Copyright © 2017 Triple6. All rights reserved.
//

import UIKit
import Photos
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage
import JSQMessagesViewController
import SwiftGifOrigin
import Alamofire

class ContactSellerViewController: JSQMessagesViewController {
    
    var channelRef: FIRDatabaseReference!
    var userId: Int!
    var userName: String!
    var userUrl: String!
    var sellerId: Int!
    var sellerName: String!
    var sellerUrl: String!
    var pid: Int!
    var messageRef: FIRDatabaseReference!
    lazy var storageRef: FIRStorageReference = FIRStorage.storage().reference(forURL: "gs://gtthriftshop-394d2.appspot.com/")
    private let imageURLNotSetKey = "NOTSET"
    private var newMessageRefHandle: FIRDatabaseHandle?
    private var updatedMessageRefHandle: FIRDatabaseHandle?
    var messages = [JSQMessage]()
    private var photoMessageMap = [String: JSQPhotoMediaItem]()
    
    lazy var outgoingBubbleImageView: JSQMessagesBubbleImage = self.setupOutgoingBubble()
    lazy var incomingBubbleImageView: JSQMessagesBubbleImage = self.setupIncomingBubble()
    
    var userAvatarImageView: JSQMessagesAvatarImage!
    var sellerAvatarImageView: JSQMessagesAvatarImage!
    
    private lazy var userIsTypingRef: FIRDatabaseReference =
        self.channelRef!.child("typingIndicator").child(self.senderId) // 1
    private var localTyping = false // 2
    var isTyping: Bool {
        get {
            return localTyping
        }
        set {
            // 3
            localTyping = newValue
            userIsTypingRef.setValue(newValue)
        }
    }
    
    private lazy var usersTypingQuery: FIRDatabaseQuery =
        self.channelRef!.child("typingIndicator").queryOrderedByValue().queryEqual(toValue: true)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if pid > -1 {
            sendInterestInBackground()
        }
        messageRef = channelRef.child("messages")
        
        self.senderId = "\(userId!)"
        self.senderDisplayName = self.userName!
        self.title = sellerName!
        // No avatars
//        collectionView!.collectionViewLayout.incomingAvatarViewSize = CGSize.zero
//        collectionView!.collectionViewLayout.outgoingAvatarViewSize = CGSize.zero
        
        if let imageData: NSData = NSData(contentsOf: URL(string: userUrl)!) {
            userAvatarImageView = JSQMessagesAvatarImage.avatar(with: UIImage(data: imageData as Data))
            
            
            
            
        } else {
            userAvatarImageView = JSQMessagesAvatarImage.avatar(with: #imageLiteral(resourceName: "GT-icon"))
        }
        
        if sellerUrl == nil {
            let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            let fileURL = documentsURL.appendingPathComponent("\(sellerId!)-avatar.jpeg")
            let filePath = fileURL.path
            if FileManager.default.fileExists(atPath: filePath) {
                sellerAvatarImageView = JSQMessagesAvatarImage.avatar(with: UIImage(contentsOfFile: filePath))
            } else {
                print("need to grab image from web")
                getSellerAvatar()
            }
        } else {
            if let imageData: NSData = NSData(contentsOf: URL(string: sellerUrl)!) {
                sellerAvatarImageView = JSQMessagesAvatarImage.avatar(with: UIImage(data: imageData as Data))
            } else {
                sellerAvatarImageView = JSQMessagesAvatarImage.avatar(with: #imageLiteral(resourceName: "GT-icon"))
            }
        }
        
        
        
        observeMessages()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        observeTyping()
    }
    
    deinit {
        if let refHandle = newMessageRefHandle {
            messageRef.removeObserver(withHandle: refHandle)
        }
        
        if let refHandle = updatedMessageRefHandle {
            messageRef.removeObserver(withHandle: refHandle)
        }
    }
    
    func getSellerAvatar() {
        Alamofire.request("http://ec2-34-196-222-211.compute-1.amazonaws.com/user/getAvatarURL/\(sellerId!)", method: .get, encoding: JSONEncoding.default).validate().responseJSON { response in
            switch response.result {
            case .success:
                print("Validation Successful")
                if let json = response.result.value {
                    print("JSON: \(json)")
                    let result = json as! NSDictionary
                    guard let sellerAvatarURL = result["avatarURL"] as? String else {
                        print("error: cannot unarchive returned data")
                        return
                    }
                    self.sellerUrl = sellerAvatarURL
                    if let imageData: NSData = NSData(contentsOf: URL(string: self.sellerUrl)!) {
                        self.sellerAvatarImageView = JSQMessagesAvatarImage.avatar(with: UIImage(data: imageData as Data))
                    } else {
                        self.sellerAvatarImageView = JSQMessagesAvatarImage.avatar(with: #imageLiteral(resourceName: "GT-icon"))
                    }
                   
                } else {
                    self.sellerAvatarImageView = JSQMessagesAvatarImage.avatar(with: #imageLiteral(resourceName: "GT-icon"))
                }
            case .failure(let error):
                print(error)
                self.sellerAvatarImageView = JSQMessagesAvatarImage.avatar(with: #imageLiteral(resourceName: "GT-icon"))
            }
        }
    }
    
    func sendInterestInBackground() {
        let url = URL(string: "http://ec2-34-196-222-211.compute-1.amazonaws.com/products/add/interest");
        
        var request = URLRequest(url:url! as URL);
        request.httpMethod = "POST";
        
        let param = [
            "userId"  : userId!,
            "pid"  : pid!
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
                if httpResponse.statusCode == 200{
                    print("interest uplaoded successfully")
                } else {
                    print("some error happened")
                }
            } else {
                print("some error happened")
            }
            
        }
        
        task.resume()
    }
    
    
    func notifyFailure(info: String) {
        GlobalHelper.sendAlart(info: info, VC: self)
    }
    
    private func addMessage(withId id: String, name: String, date: Date, text: String) {
        if let message = JSQMessage(senderId: id, senderDisplayName: name, date: date, text: text) {
            messages.append(message)
        }
    }
    
    private func addPhotoMessage(withId id: String, key: String, mediaItem: JSQPhotoMediaItem) {
        if let message = JSQMessage(senderId: id, displayName: "", media: mediaItem) {
            messages.append(message)
            
            if (mediaItem.image == nil) {
                photoMessageMap[key] = mediaItem
            }
            
            collectionView.reloadData()
        }
    }
    
    private func fetchImageDataAtURL(_ photoURL: String, forMediaItem mediaItem: JSQPhotoMediaItem, clearsPhotoMessageMapOnSuccessForKey key: String?) {
        
        let storageRef = FIRStorage.storage().reference(forURL: photoURL)
        
        storageRef.data(withMaxSize: INT64_MAX){ (data, error) in
            if let error = error {
                print("Error downloading image data: \(error)")
                return
            }
            storageRef.metadata(completion: { (metadata, metadataErr) in
                if let error = metadataErr {
                    print("Error downloading metadata: \(error)")
                    return
                }
                
                if (metadata?.contentType == "image/gif") {
                    mediaItem.image = UIImage.gif(data: data!)
                } else {
                    mediaItem.image = UIImage.init(data: data!)
                }
                self.collectionView.reloadData()
                
                guard key != nil else {
                    return
                }
                self.photoMessageMap.removeValue(forKey: key!)
            })
        }
    }
    
    func sendPhotoMessage() -> String? {
        let itemRef = messageRef.childByAutoId()
        
        let messageItem = [
            "photoURL": imageURLNotSetKey,
            "senderId": senderId!,
            ]
        
        itemRef.setValue(messageItem)
        
        JSQSystemSoundPlayer.jsq_playMessageSentSound()
        
        finishSendingMessage()
        return itemRef.key
    }
    
    func setImageURL(_ url: String, forPhotoMessageWithKey key: String) {
        let itemRef = messageRef.child(key)
        itemRef.updateChildValues(["photoURL": url])
    }
    
    private func setupOutgoingBubble() -> JSQMessagesBubbleImage {
        let bubbleImageFactory = JSQMessagesBubbleImageFactory()
        return bubbleImageFactory!.outgoingMessagesBubbleImage(with: UIColor.jsq_messageBubbleBlue())
    }
    
    private func setupIncomingBubble() -> JSQMessagesBubbleImage {
        let bubbleImageFactory = JSQMessagesBubbleImageFactory()
        return bubbleImageFactory!.incomingMessagesBubbleImage(with: UIColor.jsq_messageBubbleLightGray())
    }

    private func observeMessages() {
        messageRef = channelRef!.child("messages")
        let messageQuery = messageRef.queryLimited(toLast:100)
        
        newMessageRefHandle = messageQuery.observe(.childAdded, with: { (snapshot) -> Void in
            
            let messageData = snapshot.value as! Dictionary<String, String>
            
            if let id = messageData["senderId"] as String!, let name = messageData["senderName"] as String!, let text = messageData["text"] as String!, let interval = messageData["sendTime"] as String!, text.characters.count > 0 {
//                print("\(Date(timeIntervalSince1970: Double(interval)!))")
                self.addMessage(withId: id, name: name, date: Date(timeIntervalSince1970: Double(interval)!), text: text)
                
                self.finishReceivingMessage()
            } else if let id = messageData["senderId"] as String!,
                let photoURL = messageData["photoURL"] as String! {
                
                if let mediaItem = JSQPhotoMediaItem(maskAsOutgoing: id == self.senderId) {
                    self.addPhotoMessage(withId: id, key: snapshot.key, mediaItem: mediaItem)
                    if photoURL.hasPrefix("gs://") {
                        self.fetchImageDataAtURL(photoURL, forMediaItem: mediaItem, clearsPhotoMessageMapOnSuccessForKey: nil)
                    }
                }
            } else {
                print("Error! Could not decode message data")
            }
        })
        
        updatedMessageRefHandle = messageRef.observe(.childChanged, with: { (snapshot) in
            let key = snapshot.key
            let messageData = snapshot.value as! Dictionary<String, String>
            
            if let photoURL = messageData["photoURL"] as String! {
                // The photo has been updated.
                if let mediaItem = self.photoMessageMap[key] {
                    self.fetchImageDataAtURL(photoURL, forMediaItem: mediaItem, clearsPhotoMessageMapOnSuccessForKey: key)
                }
            }
        })
    }
    
    private func observeTyping() {
        let typingIndicatorRef = channelRef!.child("typingIndicator")
        userIsTypingRef = typingIndicatorRef.child(senderId)
        userIsTypingRef.onDisconnectRemoveValue()
        
        usersTypingQuery.observe(.value) { (data: FIRDataSnapshot) in
            // 2 You're the only one typing, don't show the indicator
            if data.childrenCount == 1 && self.isTyping {
                return
            }
            
            // 3 Are there others typing?
            self.showTypingIndicator = data.childrenCount > 0
            self.scrollToBottom(animated: true)
        }
    }
    
    func dismissFullscreenImage(_ sender: UITapGestureRecognizer) {
        self.navigationController?.navigationBar.isHidden = false
        sender.view?.removeFromSuperview()
    }
    
    func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage {
        let size = image.size
        
        let widthRatio  = targetSize.width  / image.size.width
        let heightRatio = targetSize.height / image.size.height
        
        // Figure out what our orientation is, and use that to form the rectangle
        var newSize: CGSize
        if(widthRatio > heightRatio) {
            newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
        } else {
            newSize = CGSize(width: size.width * widthRatio,  height: size.height * widthRatio)
        }
        
        // This is the rect that we've calculated out and this is what is actually used below
        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
        
        // Actually do the resizing to the rect using the ImageContext stuff
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
    
    @IBAction func cancelChat(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    //implement JSQ protocol and datasource
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageDataForItemAt indexPath: IndexPath!) -> JSQMessageData! {
        return messages[indexPath.item]
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAt indexPath: IndexPath!) -> JSQMessageBubbleImageDataSource! {
        let message = messages[indexPath.item]
        if message.senderId == senderId {
            return outgoingBubbleImageView
        } else {
            return incomingBubbleImageView
        }
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAt indexPath: IndexPath!) -> JSQMessageAvatarImageDataSource! {
        let message = messages[indexPath.item]
        if message.senderId == senderId {
            return userAvatarImageView
        } else {
            return sellerAvatarImageView
        }
    }
    
    //deal with date display later
//    override func collectionView(_ collectionView: JSQMessagesCollectionView!, attributedTextForCellTopLabelAt indexPath: IndexPath!) -> NSAttributedString! {
//        let message = messages[indexPath.item]
//        let messageDate = message.date
//        let currentDate = Date()
//        let dateFormatter = DateFormatter()
//        var dateString = NSMutableAttributedString()
//        if currentDate.minutes(from: messageDate!) == 5 {
//            dateFormatter.dateStyle = .none
//            dateFormatter.timeStyle = .short
//            dateString = NSMutableAttributedString(string: dateFormatter.string(from: messageDate!))
//        } else if (currentDate.minutes(from: messageDate!) >= 59) && (currentDate.minutes(from: messageDate!) <= 61) {
//            dateFormatter.dateStyle = .none
//            dateFormatter.timeStyle = .short
//            dateString = NSMutableAttributedString(string: dateFormatter.string(from: messageDate!))
//        } else if (currentDate.hours(from: messageDate!) >= 11) && (currentDate.hours(from: messageDate!) <= 13) {
//            dateFormatter.dateStyle = .medium
//            dateFormatter.timeStyle = .short
//            dateString = NSMutableAttributedString(string: dateFormatter.string(from: messageDate!))
//        } else if indexPath.item == 0 {
//            dateFormatter.dateStyle = .medium
//            dateFormatter.timeStyle = .short
//            dateString = NSMutableAttributedString(string: dateFormatter.string(from: messageDate!))
//        }
//        
//        return dateString
//    }
//    
//    override func collectionView(_ collectionView: JSQMessagesCollectionView!, attributedTextForMessageBubbleTopLabelAt indexPath: IndexPath!) -> NSAttributedString! {
//        let message = messages[indexPath.item]
//        let messageDate = message.date
//        let currentDate = Date()
//        let dateFormatter = DateFormatter()
//        var dateString = NSMutableAttributedString()
//        if currentDate.minutes(from: messageDate!) == 5 {
//            dateFormatter.dateStyle = .none
//            dateFormatter.timeStyle = .short
//            dateString = NSMutableAttributedString(string: dateFormatter.string(from: messageDate!))
//        } else if (currentDate.minutes(from: messageDate!) >= 59) && (currentDate.minutes(from: messageDate!) <= 61) {
//            dateFormatter.dateStyle = .none
//            dateFormatter.timeStyle = .short
//            dateString = NSMutableAttributedString(string: dateFormatter.string(from: messageDate!))
//        } else if (currentDate.hours(from: messageDate!) >= 11) && (currentDate.hours(from: messageDate!) <= 13) {
//            dateFormatter.dateStyle = .medium
//            dateFormatter.timeStyle = .short
//            dateString = NSMutableAttributedString(string: dateFormatter.string(from: messageDate!))
//        } else if indexPath.item == 0 {
//            dateFormatter.dateStyle = .medium
//            dateFormatter.timeStyle = .short
//            dateString = NSMutableAttributedString(string: dateFormatter.string(from: messageDate!))
//        }
//        
//        return dateString
//    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, didTapMessageBubbleAt indexPath: IndexPath!) {
        let message = messages[indexPath.item]
        if message.isMediaMessage {
            let mediaItem =  message.media
            if mediaItem is JSQPhotoMediaItem{
                let photoItem = mediaItem as! JSQPhotoMediaItem
                var imageToDisplay = photoItem.image //UIImage obtained.
                if imageToDisplay != nil {
                    let imageWidth = (imageToDisplay?.size.width)!
                    let imageHeight = (imageToDisplay?.size.height)!
                    if imageWidth > self.view.frame.size.width || imageHeight > self.view.frame.size.height {
                        if imageHeight > imageWidth {
                            imageToDisplay = self.resizeImage(image: imageToDisplay!, targetSize: CGSize.init(width: imageWidth * (self.view.frame.height / imageHeight), height: self.view.frame.height))
                        } else {
                            imageToDisplay = self.resizeImage(image: imageToDisplay!, targetSize: CGSize.init(width: self.view.frame.width, height: imageHeight * (self.view.frame.width / imageWidth)))
                        }
                    }
                    let newImageView = UIImageView(image: imageToDisplay)
                    newImageView.frame = self.view.frame
                    newImageView.backgroundColor = .black
                    newImageView.contentMode = .center
                    newImageView.isUserInteractionEnabled = true
                    let tap = UITapGestureRecognizer(target: self, action: #selector(dismissFullscreenImage))
                    newImageView.addGestureRecognizer(tap)
                    self.view.addSubview(newImageView)
                    self.view.bringSubview(toFront: newImageView)
                    self.navigationController?.navigationBar.isHidden = true
                }
            }
            
        }
    }

    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = super.collectionView(collectionView, cellForItemAt: indexPath) as! JSQMessagesCollectionViewCell
        let message = messages[indexPath.item]
        if message.senderId == senderId {
            cell.textView?.textColor = UIColor.white
        } else {
            cell.textView?.textColor = UIColor.black
        }

        
        return cell
    }
    
    override func didPressSend(_ button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: Date!) {
        let itemRef = messageRef.childByAutoId()
        let messageItem: [String : Any] = [
            "senderId": senderId!,
            "senderName": senderDisplayName!,
            "text": text!,
            "sendTime": "\(date.timeIntervalSince1970)"
            ]
        
        itemRef.setValue(messageItem)
    
        JSQSystemSoundPlayer.jsq_playMessageSentSound()
        finishSendingMessage()
        
        isTyping = false
    }
    
    override func didPressAccessoryButton(_ sender: UIButton) {
        let picker = UIImagePickerController()
        picker.delegate = self
        if (UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera)) {
            picker.sourceType = UIImagePickerControllerSourceType.camera
        } else {
            picker.sourceType = UIImagePickerControllerSourceType.photoLibrary
        }
        
        present(picker, animated: true, completion:nil)
    }
    
    override func textViewDidChange(_ textView: UITextView) {
        super.textViewDidChange(textView)
        // If the text is not empty, the user is typing
        isTyping = textView.text != ""
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

// MARK: Image Picker Delegate
extension ContactSellerViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [String : Any]) {
        
        picker.dismiss(animated: true, completion:nil)
        
        // 1
        if let photoReferenceUrl = info[UIImagePickerControllerReferenceURL] as? URL {
            // Handle picking a Photo from the Photo Library
            // 2
            let assets = PHAsset.fetchAssets(withALAssetURLs: [photoReferenceUrl], options: nil)
            let asset = assets.firstObject
            
            // 3
            if let key = sendPhotoMessage() {
                // 4
                asset?.requestContentEditingInput(with: nil, completionHandler: { (contentEditingInput, info) in
                    let imageFileURL = contentEditingInput?.fullSizeImageURL
                    
                    // 5
                    let path = "\(FIRAuth.auth()?.currentUser?.uid)/\(Int(Date.timeIntervalSinceReferenceDate * 1000))/\(photoReferenceUrl.lastPathComponent)"
                    
                    // 6
                    self.storageRef.child(path).putFile(imageFileURL!, metadata: nil) { (metadata, error) in
                        if let error = error {
                            print("Error uploading photo: \(error.localizedDescription)")
                            return
                        }
                        // 7
                        self.setImageURL(self.storageRef.child((metadata?.path)!).description, forPhotoMessageWithKey: key)
                    }
                })
            }
        } else {
            // Handle picking a Photo from the Camera - TODO
            // 1
            let image = info[UIImagePickerControllerOriginalImage] as! UIImage
            // 2
            if let key = sendPhotoMessage() {
                // 3
                let imageData = UIImageJPEGRepresentation(image, 1.0)
                // 4
                let imagePath = FIRAuth.auth()!.currentUser!.uid + "/\(Int(Date.timeIntervalSinceReferenceDate * 1000)).jpg"
                // 5
                let metadata = FIRStorageMetadata()
                metadata.contentType = "image/jpeg"
                // 6
                storageRef.child(imagePath).put(imageData!, metadata: metadata) { (metadata, error) in
                    if let error = error {
                        print("Error uploading photo: \(error)")
                        return
                    }
                    // 7
                    self.setImageURL(self.storageRef.child((metadata?.path)!).description, forPhotoMessageWithKey: key)
                }
            }
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion:nil)
    }
}

extension Date {
    /// Returns the amount of years from another date
    func years(from date: Date) -> Int {
        return Calendar.current.dateComponents([.year], from: date, to: self).year ?? 0
    }
    /// Returns the amount of months from another date
    func months(from date: Date) -> Int {
        return Calendar.current.dateComponents([.month], from: date, to: self).month ?? 0
    }
    /// Returns the amount of weeks from another date
    func weeks(from date: Date) -> Int {
        return Calendar.current.dateComponents([.weekOfYear], from: date, to: self).weekOfYear ?? 0
    }
    /// Returns the amount of days from another date
    func days(from date: Date) -> Int {
        return Calendar.current.dateComponents([.day], from: date, to: self).day ?? 0
    }
    /// Returns the amount of hours from another date
    func hours(from date: Date) -> Int {
        return Calendar.current.dateComponents([.hour], from: date, to: self).hour ?? 0
    }
    /// Returns the amount of minutes from another date
    func minutes(from date: Date) -> Int {
        return Calendar.current.dateComponents([.minute], from: date, to: self).minute ?? 0
    }
    /// Returns the amount of seconds from another date
    func seconds(from date: Date) -> Int {
        return Calendar.current.dateComponents([.second], from: date, to: self).second ?? 0
    }
    /// Returns the a custom time interval description from another date
    func offset(from date: Date) -> String {
        if years(from: date)   > 0 { return "\(years(from: date))y"   }
        if months(from: date)  > 0 { return "\(months(from: date))M"  }
        if weeks(from: date)   > 0 { return "\(weeks(from: date))w"   }
        if days(from: date)    > 0 { return "\(days(from: date))d"    }
        if hours(from: date)   > 0 { return "\(hours(from: date))h"   }
        if minutes(from: date) > 0 { return "\(minutes(from: date))m" }
        if seconds(from: date) > 0 { return "\(seconds(from: date))s" }
        return ""
    }
}

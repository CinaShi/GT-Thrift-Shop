//
//  Product.swift
//  GTThriftShop
//
//  Created by Mengyang Shi on 2/17/17.
//  Copyright © 2017 Triple6. All rights reserved.
//

import UIKit

class Product: NSObject, NSCoding {
    var imageUrls: [String]!
    let name: String!
    let price: String!
    let info: String!
    let pid: Int!
    let postTime: String!
    let usedTime: String!
    let userId: Int!
    let userName: String!
    var isSold: Bool!
    
    init(name: String, price: String, info: String, pid: Int, postTime: String, usedTime: String, userId: Int, userName: String, imageUrls: [String], isSold: Bool) {
        self.name = name
        self.price = price
        self.info = info
        self.pid = pid
        self.postTime = postTime
        self.usedTime = usedTime
        self.userId = userId
        self.userName = userName
        self.imageUrls = imageUrls
        self.isSold = isSold
    }
    
    required init(coder decoder: NSCoder) {
        self.name = decoder.decodeObject(forKey: "name") as! String
        self.price = decoder.decodeObject(forKey: "price") as! String
        self.info = decoder.decodeObject(forKey: "info") as! String
        self.pid = decoder.decodeInteger(forKey: "pid")
        self.postTime = decoder.decodeObject(forKey: "postTime") as! String
        self.usedTime = decoder.decodeObject(forKey: "usedTime") as! String
        self.userId = decoder.decodeInteger(forKey: "userId")
        self.userName = decoder.decodeObject(forKey: "userName") as! String
        self.imageUrls = decoder.decodeObject(forKey: "imageUrls") as! [String]
        self.isSold = decoder.decodeBool(forKey: "isSold")
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(name, forKey: "name")
        aCoder.encode(price, forKey: "price")
        aCoder.encode(info, forKey: "info")
        if let pid = pid {
            aCoder.encode(pid, forKey: "pid")
        }
        aCoder.encode(postTime, forKey: "postTime")
        aCoder.encode(usedTime, forKey: "usedTime")
        if let userId = userId {
            aCoder.encode(userId, forKey: "userId")
        }
        aCoder.encode(userName, forKey: "userName")
        aCoder.encode(imageUrls, forKey: "imageUrls")
        if let isSold = isSold {
            aCoder.encode(isSold, forKey: "isSold")
        }
        
    }
    
    func setSold() {
        if self.isSold == false {
            self.isSold = true
        }
    }
}

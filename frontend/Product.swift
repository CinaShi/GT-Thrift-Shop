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
    
    init(name: String, price: String, info: String, pid: Int, postTime: String, usedTime: String, userId: Int, imageUrls: [String]) {
        self.name = name
        self.price = price
        self.info = info
        self.pid = pid
        self.postTime = postTime
        self.usedTime = usedTime
        self.userId = userId
        self.imageUrls = imageUrls
    }
    
    required init(coder decoder: NSCoder) {
        self.name = decoder.decodeObject(forKey: "name") as! String
        self.price = decoder.decodeObject(forKey: "price") as! String
        self.info = decoder.decodeObject(forKey: "info") as! String
        self.pid = decoder.decodeInteger(forKey: "pid") 
        self.postTime = decoder.decodeObject(forKey: "postTime") as! String
        self.usedTime = decoder.decodeObject(forKey: "usedTime") as! String
        self.userId = decoder.decodeInteger(forKey: "userId")
        self.imageUrls = decoder.decodeObject(forKey: "imageUrls") as! [String]
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(name, forKey: "name")
        aCoder.encode(price, forKey: "price")
        aCoder.encode(info, forKey: "info")
        aCoder.encode(pid, forKey: "pid")
        aCoder.encode(postTime, forKey: "postTime")
        aCoder.encode(usedTime, forKey: "usedTime")
        aCoder.encode(userId, forKey: "userId")
        aCoder.encode(imageUrls, forKey: "imageUrls")
        
    }
}

//
//  User.swift
//  GTThriftShop
//
//  Created by Mengyang Shi on 4/11/17.
//  Copyright © 2017 Triple6. All rights reserved.
//

import UIKit

class User: NSObject, NSCoding {
    let uid: Int!
    let nickname: String!
    let email: String!
    let info: String!
    let rate: Float!
    let avatarURL: String!
    
    init(uid: Int, nickname: String, email: String, info: String, rate: Float, avatarURL: String) {
        self.uid = uid
        self.nickname = nickname
        self.email = email
        self.info = info
        self.rate = rate
        self.avatarURL = avatarURL
    }
    
    required init(coder decoder: NSCoder) {
        self.uid = decoder.decodeInteger(forKey: "uid")
        self.nickname = decoder.decodeObject(forKey: "nickname") as! String
        self.email = decoder.decodeObject(forKey: "email") as! String
        self.info = decoder.decodeObject(forKey: "info") as! String
        self.rate = decoder.decodeFloat(forKey: "rate")
        self.avatarURL = decoder.decodeObject(forKey: "avatarURL") as! String
    }
    
    func encode(with aCoder: NSCoder) {
        if let uid = uid {
            aCoder.encode(uid, forKey: "uid")
        }
        aCoder.encode(nickname, forKey: "nickname")
        aCoder.encode(email, forKey: "email")
        aCoder.encode(info, forKey: "info")
        if let rate = rate {
            aCoder.encode(rate, forKey: "rate")
        }
        aCoder.encode(avatarURL, forKey: "avatarURL")
    }
    
    func isCurrentUser(anotherId: Int) -> Bool {
        return anotherId == self.uid
    }
}

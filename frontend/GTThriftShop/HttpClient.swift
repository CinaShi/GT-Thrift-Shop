//
//  HttpClient.swift
//  T-Squared for Georgia Tech
//
//  Created by Cal on 8/26/15.
//  Copyright © 2015 Cal Stephens. All rights reserved.
//

import Foundation

import UIKit

let TSNetworkQueue = DispatchQueue(label: "edu.gatech.cal.network-queue", attributes: DispatchQueue.Attributes.concurrent)

class HttpClient {
    
    //MARK: - HTTP implementation
    
    fileprivate var url: URL?
    fileprivate var session: URLSession
    
    internal init(url: String, useMobile: Bool = true) {
        self.url = URL(string: url)
        
        let config = URLSessionConfiguration.default
        config.requestCachePolicy = NSURLRequest.CachePolicy.reloadIgnoringLocalCacheData
        if useMobile {
            config.httpAdditionalHeaders = ["User-Agent": "Mozilla/5.0 (iPhone; CPU iPhone OS 8_0 like Mac OS X) AppleWebKit/600.1.3 (KHTML, like Gecko) Version/8.0 Mobile/12A4345d Safari/600.1.4"]
        }
        self.session = URLSession(configuration: config)
        //URLCache.setSharedURLCache(SwizzlingNSURLCache(memoryCapacity: 0, diskCapacity: 0, diskPath: nil))
        
        session.configuration.httpShouldSetCookies = true
        session.configuration.httpCookieAcceptPolicy = HTTPCookie.AcceptPolicy.always
        session.configuration.httpCookieStorage?.cookieAcceptPolicy = HTTPCookie.AcceptPolicy.always
        session.configuration.requestCachePolicy = .reloadIgnoringLocalCacheData
    }
    
    internal func sendGet() -> String? {
        URLCache.shared.removeAllCachedResponses()
        
        var attempts = 0
        var failed = false
        var stopTrying = false
        var ready = false
        var content: String!
        guard let url = self.url else { return nil }
        
        let request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 5.0)
        
        while !stopTrying && !ready {
            
            failed = false
            
            let task = URLSession.shared.dataTask(with: request, completionHandler: {
                (data, response, error) -> Void in
                if let data = data {
                    if let loadedContent = NSString(data: data, encoding: String.Encoding.ascii.rawValue) {
                        content = loadedContent as String
                        ready = true
                        return
                    }
                }
                
                attempts += 1
                failed = true
                if attempts >= 3 {
                    stopTrying = true
                }
                
            }) 
            
            task.resume()
            while !ready && !failed && !stopTrying {
                usleep(100000)
            }
            
            if content != nil || stopTrying {
                return content
            }
        
        }
        
        return content
    }
    
    internal func setUrl(_ url: String) {
        self.url = URL(string: url)
    }
    
    static func getInfoFromPage(_ page: NSString, infoSearch: String, terminator: String = "\"") -> String? {
        let position = page.range(of: infoSearch)
        let location = position.location
        if location > page.length {
            return nil
        }
        let containsInfo = (page.substring(to: min(location + 300, page.length - 1)) as NSString).substring(from: min(location + infoSearch.characters.count, page.length - 1))
        let characters = containsInfo.characters
        
        var info = ""
        for character in characters {
            let char = "\(character)"
            if char == terminator { break }
            info += char
        }
        
        return info
    }
    
    static func clearCookies() {
        let cookies = HTTPCookieStorage.shared
        for cookie in (cookies.cookies ?? []) {
            cookies.deleteCookie(cookie)
        }
    }
    
    
    //MARK: - HTTP Requests
    
}

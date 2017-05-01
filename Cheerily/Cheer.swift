//
//  Cheer.swift
//  Cheerily
//
//  Created by Roman Sheydvasser on 4/29/17.
//  Copyright © 2017 RLabs. All rights reserved.
//

import Foundation

struct Cheer {
    // MARK: Properties
    
    let title: String
    let url: String
    let type: String
    let permalink: String
    let mediaData: Data?
    
    // MARK: Initializers
    
    // construct a Cheer from a dictionary
    init(dictionary: [String:AnyObject]) {
        title = dictionary["data"]?["title"] as! String
        url = dictionary["data"]?["url"] as! String
        permalink = dictionary["data"]?["permalink"] as! String
        
        let urlNSString = url as NSString
        type = urlNSString.pathExtension as String
        mediaData = nil
    }
    
    static func cheersFromResults(_ results: [[String:AnyObject]]) -> [Cheer] {
        var cheers = [Cheer]()
        for result in results {
            cheers.append(Cheer(dictionary: result))
        }
        return cheers
    }
}

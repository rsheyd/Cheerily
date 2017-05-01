//
//  RedditClient.swift
//  Cheerily
//
//  Created by Roman Sheydvasser on 4/29/17.
//  Copyright © 2017 RLabs. All rights reserved.
//

import Foundation

extension WebClient {
    func getNewAwws(completionHandler: () -> Void) {
        sessionManager.adapter = AccessTokenAdapter(accessToken: "h8MU3FD-WX3rxgLFntDgPQTWHag", forBaseUrl: Constants.redditTokenBaseUrl)
        sessionManager.request("https://oauth.reddit.com/r/aww/hot")
            .responseJSON { response in
                print("result: \(response.result)")
                
                guard let JSON = response.result.value as? [String:AnyObject],
                    let extData = JSON["data"] as? [String:AnyObject],
                    let posts = extData["children"] as? [[String:AnyObject]] else {
                        return
                }
                
                let cheers = Cheer.cheersFromResults(posts)
                print("New cheers count: \(cheers.count)")
                CheerStore.sharedInstance().cheers = cheers
                completionHandler()
        }
    }
    
    func downloadImage(completionHandler: () -> Void) {
        
    }
}

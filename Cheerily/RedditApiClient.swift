//
//  RedditClient.swift
//  Cheerily
//
//  Created by Roman Sheydvasser on 4/29/17.
//  Copyright © 2017 RLabs. All rights reserved.
//

import Foundation
import Alamofire

extension WebClient {
    func getNewAwws(completionHandler: @escaping () -> Void) {
        guard let accessToken = accessToken else {
            print("Error. No access token.")
            return
        }
        
        sessionManager.adapter =
            AccessTokenAdapter(accessToken: accessToken,
                               forBaseUrl: Constants.redditTokenBaseUrl)
        sessionManager.request("https://oauth.reddit.com/r/aww/hot")
            .responseJSON { response in
                guard let JSON = response.result.value as? [String:AnyObject] else {
                    return
                }
                print(JSON)
                
                // renew token with refresh token if 401 error is returned
                if JSON["error"] as? String == "401" {
                    self.renewToken() {
                        self.getNewAwws() {
                            completionHandler()
                        }
                    }
                    return
                }
                
                guard let extData = JSON["data"] as? [String:AnyObject],
                    let posts = extData["children"] as? [[String:AnyObject]] else {
                        return
                }
                
                let cheers = Cheer.cheersFromResults(posts)
                print("New cheers count: \(cheers.count)")
                print(cheers.last!.url)
                CheerStore.sharedInstance().cheers = cheers
                completionHandler()
        }
    }
    

}

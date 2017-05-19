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
    
    func getNewAwws(triedRenewingToken: Bool, completionHandler: @escaping () -> Void) {
        guard let accessToken = accessToken else {
            print("Error. No access token.")
            return
        }
        
        var parameters: Parameters = [:]
        
        if let afterId = lastPostId {
            parameters = ["after": afterId]
        }
        
        print(parameters)
        
        sessionManager.adapter =
            AccessTokenAdapter(accessToken: accessToken,
                               forBaseUrl: Constants.redditTokenBaseUrl)
        
        sessionManager.request("https://oauth.reddit.com/r/aww/hot", parameters: parameters)
            .responseJSON { response in
                guard let JSON = response.result.value as? [String:AnyObject] else {
                    return
                }
                
                if JSON["error"] as? Int == 401 {
                    if !triedRenewingToken {
                        self.renewToken() {
                            self.getNewAwws(triedRenewingToken: true) {
                                completionHandler()
                            }
                        }
                    } else {
                        Helper.displayAlertOnMain("Error accessing reddit API or renewing access token. Try again later.")
                        return
                    }
                    return
                }
                
                guard let extData = JSON["data"] as? [String:AnyObject],
                    let afterId = extData["after"] as? String,
                    let posts = extData["children"] as? [[String:AnyObject]] else {
                        return
                }
                
                self.lastPostId = afterId
                print(String(describing: self.lastPostId))
                let cheers = Cheer.cheersFromResults(posts)
                if cheers.count == 0 {
                    print("No cheers generated from getNewAwws.")
                    return
                }
                print("New cheers count: \(cheers.count)")
                print(cheers.last!.url)
                CheerStore.sharedInstance.loadCoreCheers()
                completionHandler()
        }
    }
}

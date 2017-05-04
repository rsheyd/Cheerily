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
        
        sessionManager.adapter =
            AccessTokenAdapter(accessToken: accessToken,
                               forBaseUrl: Constants.redditTokenBaseUrl)
        sessionManager.request("https://oauth.reddit.com/r/aww/hot")
            .responseJSON { response in
                guard let JSON = response.result.value as? [String:AnyObject] else {
                    return
                }
                print(JSON)
                
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

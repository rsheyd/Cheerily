//
//  RedditClient.swift
//  Cheerily
//
//  Created by Roman Sheydvasser on 4/29/17.
//  Copyright © 2017 RLabs. All rights reserved.
//

import Foundation

extension WebClient {
    func getNewAwws() {
        sessionManager.adapter = AccessTokenAdapter(accessToken: "5HfWtEOZWfyXep7vT13Jt_7lVw0", forBaseUrl: Constants.redditTokenBaseUrl)
        sessionManager.request("https://oauth.reddit.com/r/aww/hot")
            .responseJSON { response in
                print("result: \(response.result)")
                if let JSON = response.result.value as? [String:Any] {
                    print("JSON: \(JSON)")
                }
        }
    }
}

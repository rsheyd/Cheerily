//
//  Constants.swift
//  Cheerily
//
//  Created by Roman Sheydvasser on 4/27/17.
//  Copyright © 2017 RLabs. All rights reserved.
//

import Foundation

extension WebClient {
    struct Constants {
        static let redditBaseAuthUrl = "https://www.reddit.com/api/v1/authorize.compact?"
        static let redditClientId = "VaDafNnznGCs3A"
        static let redditRedirectUri = "cheerily://oauth-callback"
        static let redditAccessTokenUrl = "https://www.reddit.com/api/v1/access_token"
    }
}

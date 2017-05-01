//
//  RedditClient.swift
//  Cheerily
//
//  Created by Roman Sheydvasser on 4/25/17.
//  Copyright © 2017 RLabs. All rights reserved.
//

import Foundation
import Alamofire

class WebClient: NSObject {
    
    var tempState: String?
    var authCode: String?
    var accessToken: String?
    var refreshToken: String?
    let sessionManager = SessionManager()
    
    func getValueFromUrlParameter(url: String, parameter: String) -> String? {
        let queryItems = URLComponents(string: url)?.queryItems
        let param1 = queryItems?.filter({$0.name == parameter}).first
        return param1?.value
    }
    
    func parseRedirectUri(_ uri: URL) -> [String:String]? {
        var uriParameters: [String:String] = [:]
        
        if let code = getValueFromUrlParameter(url: uri.absoluteString, parameter: "code"),
            let state = getValueFromUrlParameter(url: uri.absoluteString, parameter: "state") {
                uriParameters["code"] = code
                self.authCode = code
                uriParameters["state"] = state
        } else {
            Helper.displayAlertOnMain("Could not parse redirect URI.")
            return nil
        }
        
        return uriParameters
    }
    
    func createRandomState() -> String? {
        tempState = String.random()
        return tempState
    }
    
    func getRedditAuthUrl() -> String? {
        if let randomState = createRandomState() {
            let authUrl = "\(Constants.redditBaseAuthUrl)client_id=\(Constants.redditClientId)&response_type=code&state=\(randomState)&redirect_uri=\(Constants.redditRedirectUri)&duration=permanent&scope=read"
            print("Auth URL being sent: \(authUrl)")
            return authUrl
        } else {
            return nil
        }
    }
    
    func requestAccessToken() {
        guard let authCode = self.authCode else {
            return
        }
        
        let parameters: Parameters = [
            "grant_type": "authorization_code",
            "code": authCode,
            "redirect_uri": Constants.redditRedirectUri
        ]
        
        print("parameters are \(parameters)")
        
        Alamofire.request(Constants.redditAccessTokenUrl, method: .post, parameters: parameters, encoding: URLEncoding.httpBody)
                .authenticate(user: Constants.redditClientId, password: "")
                .responseJSON { response in
                    print("result: \(response.result)")
                    
                    guard let JSON = response.result.value as? [String:Any] else {
                        return
                    }
                    
                    self.accessToken = JSON["access_token"] as? String
                    self.refreshToken = JSON["refresh_token"] as? String
                    if let accessToken = self.accessToken {
                        self.sessionManager.adapter = AccessTokenAdapter(accessToken: accessToken, forBaseUrl: Constants.redditTokenBaseUrl)
                    }
                    print("JSON: \(JSON)")
        }
    }
    
    func doRefreshToken() {
        guard let refreshToken = self.refreshToken else {
            return
        }
        
        let parameters: Parameters = [
            "grant_type": "refresh_token",
            "refresh_token": refreshToken
        ]
        
        Alamofire.request(Constants.redditAccessTokenUrl, method: .post, parameters: parameters, encoding: URLEncoding.httpBody)
            .authenticate(user: Constants.redditClientId, password: "")
            .responseJSON { response in
                print("result: \(response.result)")
                if let JSON = response.result.value as? [String:Any] {
                    print("JSON: \(JSON)")
                }
        }
    }
    
    class func sharedInstance() -> WebClient {
        struct Singleton {
            static var sharedInstance = WebClient()
        }
        return Singleton.sharedInstance
    }
}

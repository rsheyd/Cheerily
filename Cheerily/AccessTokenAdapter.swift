//
//  AccessTokenAdapter.swift
//  Cheerily
//
//  Created by Roman Sheydvasser on 4/29/17.
//  Copyright © 2017 RLabs. All rights reserved.
//

import Foundation
import Alamofire

class AccessTokenAdapter: RequestAdapter {
    private let accessToken: String
    private let baseUrl: String
    
    init(accessToken: String, forBaseUrl: String) {
        self.accessToken = accessToken
        self.baseUrl = forBaseUrl
    }
    
    func adapt(_ urlRequest: URLRequest) throws -> URLRequest {
        var urlRequest = urlRequest
        
        if let urlString = urlRequest.url?.absoluteString, urlString.hasPrefix(baseUrl) {
            urlRequest.setValue("bearer " + accessToken, forHTTPHeaderField: "Authorization")
        }
        
        return urlRequest
    }
}

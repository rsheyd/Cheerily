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
        sessionManager.adapter =
            AccessTokenAdapter(accessToken: "ZCTs3JWRlD7DAe1H8r3mG-nBGno",
                               forBaseUrl: Constants.redditTokenBaseUrl)
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
                print(cheers.last!.url)
                CheerStore.sharedInstance().cheers = cheers
                completionHandler()
        }
    }
    
    func downloadImage(url: String, completionHandler: @escaping (_ data: Data) -> Void) {
        let destination: DownloadRequest.DownloadFileDestination = { _, _ in
            let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            return (documentsURL, [.removePreviousFile, .createIntermediateDirectories])
        }
        
        Alamofire.download(url, to: destination)
            .responseData { response in
                print(response)
                if let data = response.result.value {
                    print("data received")
                    completionHandler(data)
                }
        }
    }
}

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
    var lastPostId: String?
    let sessionManager = SessionManager()
    
    func getValueFromUrlParameter(url: String, parameter: String) -> String? {
        let queryItems = URLComponents(string: url)?.queryItems
        let param1 = queryItems?.filter({$0.name == parameter}).first
        return param1?.value
    }
    
    func downloadImage(url: String, completionHandler: @escaping (_ success: Bool, _ data: Data?) -> Void) {
        let destination: DownloadRequest.DownloadFileDestination = { _, _ in
            var documentsURL = FileManager.default.urls(for: .documentDirectory,
                                                        in: .userDomainMask)[0]
            documentsURL.appendPathComponent("image")
            return (documentsURL, [.removePreviousFile, .createIntermediateDirectories])
        }
        
        Alamofire.download(url, to: destination).responseData { response in
            print(response)
            if let error = response.result.error {
                Helper.displayAlertOnMain(error.localizedDescription)
                completionHandler(false, nil)
            }
            if let data = response.result.value {
                print("Data received.")
                completionHandler(true, data)
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

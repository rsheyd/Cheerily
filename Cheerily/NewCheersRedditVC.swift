//
//  AuthWithRedditVC.swift
//  Cheerily
//
//  Created by Roman Sheydvasser on 5/3/17.
//  Copyright © 2017 RLabs. All rights reserved.
//

import SafariServices

extension NewCheersVC {
    
    func checkRedditToken() {
        webClient.checkForToken() { exists in
            if exists {
                print("We have token.")
                self.getNextCheer()
            } else {
                Helper.displayAlertOnMain("Before you can use this app, you need to authorize it with Reddit.")
                self.authWithReddit()
            }
        }
    }
    
    func authWithReddit() {
        if let redditUrl = webClient.getRedditAuthUrl(), let url = URL(string: redditUrl) {
            svc = SFSafariViewController(url: url)
            svc.delegate = self
            self.present(svc, animated: true, completion: nil)
        } else {
            Helper.displayAlertOnMain("Reddit authorization URL is invalid.")
        }
    }
    
    func userHasAuthorized(notification: NSNotification) {
        if let url = notification.object as? URL {
            webClient.parseRedirectUri(url)
        } else {
            Helper.displayAlertOnMain("Received notification was not a URL.")
        }
        self.svc.dismiss(animated: true, completion: nil)
        webClient.requestAccessToken() { success in
            if success {
                self.getNextCheer()
            } else {
                Helper.displayAlertOnMain("Could not get reddit access token.")
            }
        }
    }
    
    func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        controller.dismiss(animated: true, completion: nil)
    }
}

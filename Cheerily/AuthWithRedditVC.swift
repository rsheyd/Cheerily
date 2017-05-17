//
//  AuthWithRedditVC.swift
//  Cheerily
//
//  Created by Roman Sheydvasser on 5/3/17.
//  Copyright © 2017 RLabs. All rights reserved.
//

import SafariServices

extension NewCheersVC {
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
        getNextCheer()
    }
    
    func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        controller.dismiss(animated: true, completion: nil)
    }
}

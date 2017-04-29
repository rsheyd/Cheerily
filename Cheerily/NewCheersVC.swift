//
//  ViewController.swift
//  Cheerily
//
//  Created by Roman Sheydvasser on 4/25/17.
//  Copyright © 2017 RLabs. All rights reserved.
//

import UIKit
import SafariServices

let kCloseSafariViewControllerNotification = "kCloseSafariViewControllerNotification"

class NewCheersVC: UIViewController, SFSafariViewControllerDelegate {

    var svc: SFSafariViewController!
    var redditUrl = WebClient.sharedInstance().getRedditAuthUrl()
    var state: String?
    var code: String?
    
    @IBOutlet weak var imageView: UIImageView!
    
    @IBAction func authRedditPressed(_ sender: Any) {
        if let redditUrl = redditUrl, let url = URL(string: redditUrl) {
            svc = SFSafariViewController(url: url)
            svc.delegate = self
            self.present(svc, animated: true, completion: nil)
        } else {
            Helper.displayAlertOnMain("Reddit authorization URL is invalid.")
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(userHasAuthorized), name: NSNotification.Name(rawValue: kCloseSafariViewControllerNotification), object: nil)
    }
    
    func userHasAuthorized(notification: NSNotification) {
        if let url = notification.object as? URL,
            let uriParameters = WebClient.sharedInstance().parseRedirectUri(url) {
                self.code = uriParameters["code"]
                self.state = uriParameters["state"]
                print("Returned redirect uri: \(url)")
                print(uriParameters)
        } else {
            Helper.displayAlertOnMain("Redirect URI could not be parsed.")
        }
        
        self.svc.dismiss(animated: true, completion: nil)
        WebClient.sharedInstance().requestAccessToken()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        controller.dismiss(animated: true, completion: nil)
    }
}


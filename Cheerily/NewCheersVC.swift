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
    let webClient = WebClient.sharedInstance()
    var redditUrl = WebClient.sharedInstance().getRedditAuthUrl()
    let cheerStore = CheerStore.sharedInstance()
    var validCheers: [Cheer] = []
    var nextPhotoIndex = 0
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBAction func getNewPressed(_ sender: Any) {
        if validCheers.count < 1 {
            webClient.getNewAwws() {
                self.validCheers = self.cheerStore.cheers.filter { $0.type == "jpg" }
                self.downloadAndSetImage()
            }
        } else if validCheers.count > nextPhotoIndex {
            downloadAndSetImage()
        } else {
            print("No more pictures.")
        }
    }
    
    func downloadAndSetImage() {
        webClient.downloadImage(url: validCheers[nextPhotoIndex].url) { data in
            DispatchQueue.main.async {
                self.imageView.image = UIImage(data: data)
                self.titleLabel.text = self.validCheers[self.nextPhotoIndex].title
                self.nextPhotoIndex = self.nextPhotoIndex + 1
            }
        }
    }
    
    func authWithReddit() {
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
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        webClient.checkForToken() { exists in
            if exists {
                print("We have token.")
            } else {
                Helper.displayAlertOnMain("Before you can use this app, you need to authorize it with Reddit.")
                self.authWithReddit()
            }
        }
    }
    
    func userHasAuthorized(notification: NSNotification) {
        if let url = notification.object as? URL {
            webClient.parseRedirectUri(url)
        } else {
            Helper.displayAlertOnMain("Received notification was not a URL.")
        }
        self.svc.dismiss(animated: true, completion: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        controller.dismiss(animated: true, completion: nil)
    }
}


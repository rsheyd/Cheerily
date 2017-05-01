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
    var state: String?
    var code: String?
    let cheerStore = CheerStore.sharedInstance()
    var validCheers: [Cheer] = []
    var nextPhotoIndex = 0
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBAction func getNewPressed(_ sender: Any) {
        if validCheers.count < 1 {
            webClient.getNewAwws() {
                self.validCheers = self.cheerStore.cheers.filter { $0.type == "jpg" }
                self.webClient.downloadImage(url: self.validCheers[self.nextPhotoIndex].url) { data in
                    DispatchQueue.main.async {
                        self.imageView.image = UIImage(data: data)
                        self.titleLabel.text = self.validCheers[self.nextPhotoIndex].title
                        self.nextPhotoIndex = self.nextPhotoIndex + 1
                    }
                }
            }
        } else {
            webClient.downloadImage(url: validCheers[nextPhotoIndex].url) { data in
                DispatchQueue.main.async {
                    self.imageView.image = UIImage(data: data)
                    self.titleLabel.text = self.validCheers[self.nextPhotoIndex].title
                    self.nextPhotoIndex = self.nextPhotoIndex + 1
                }
            }
        }
    }
    
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


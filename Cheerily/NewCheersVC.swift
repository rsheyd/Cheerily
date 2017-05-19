//
//  ViewController.swift
//  Cheerily
//
//  Created by Roman Sheydvasser on 4/25/17.
//  Copyright © 2017 RLabs. All rights reserved.
//

import UIKit
import SafariServices
import CoreData

let kCloseSafariViewControllerNotification = "kCloseSafariViewControllerNotification"

class NewCheersVC: UIViewController, SFSafariViewControllerDelegate {

    var svc: SFSafariViewController!
    let webClient = WebClient.sharedInstance
    let cheerStore = CheerStore.sharedInstance
    var coreCheers: [NSManagedObject] = []
    var nextPhotoIndex = 0
    
    @IBOutlet weak var customTitleField: UITextField!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var moarButton: UIButton!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var mySavesButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    // MARK: - UI AND APP STATE
    
    @IBAction func logoutPressed(_ sender: Any) {
        print("Logout pressed.")
        webClient.revokeToken { success in
            if success {
                Helper.displayAlertOnMain("You have successfully revoked Cheerily's Reddit authorization and logged out.")
            } else {
                Helper.displayAlertOnMain("Sorry, there was an issue logging you out of Reddit. Please try later.")
            }
        }
    }
    
    @IBAction func saveButtonPressed(_ sender: Any) {
        if var title = titleLabel.text, let image = imageView.image,
            let data = UIImagePNGRepresentation(image) {
            if let customTitle = customTitleField.text, customTitle != "" {
                title = customTitle
            }
            let newSavedCheer = SavedCheerModel(title: title, imageData: data)
            cheerStore.saveSavedCheer(newSavedCheer)
            saveButton.isEnabled = false
            Helper.displayAlertOnMain("Saved!")
            
        } else {
            Helper.displayAlertOnMain("Sorry, we could not save this cheer.")
        }
    }
    
    @IBAction func getNewPressed(_ sender: Any) {
        customTitleField.text = ""
        getNextCheer()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(userHasAuthorized), name: NSNotification.Name(rawValue: kCloseSafariViewControllerNotification), object: nil)
        cheerStore.loadCoreCheers()
        self.coreCheers = cheerStore.coreCheers
        checkRedditToken()
    }
    
    func enableUI(_ enabled: Bool) {
        moarButton.isEnabled = enabled
        saveButton.isEnabled = enabled
        activityIndicator.isHidden = enabled
        imageView.isHidden = !enabled
        titleLabel.isHidden = !enabled
        if enabled {
            activityIndicator.stopAnimating()
        } else {
            activityIndicator.startAnimating()
        }
    }
    
    // MARK: - LOADING NEW CHEERS
    
    func getNextCheer() {
        enableUI(false)
        if coreCheers.count < 1 {
            webClient.getNewAwws(triedRenewingToken: false) {
                self.setAndCheckNewCheers()
            }
        } else if coreCheers.count > nextPhotoIndex {
            downloadAndSetImage() {
                if (self.coreCheers.count - self.nextPhotoIndex) < 5 {
                    print("Last few pic links coming up. Will try to get more.")
                    self.getNewCheers()
                }
            }
        } else {
            print("Something went wrong and there are no more picture links. Woops.")
            Helper.displayAlertOnMain("There was an error. Please restart app.")
        }
    }
    
    func getNewCheers() {
        webClient.getNewAwws(triedRenewingToken: false) {
            self.coreCheers = self.cheerStore.coreCheers
            self.nextPhotoIndex = 0
            // if all new cheers were duplicates, do another try
            if self.coreCheers.count == 0 {
                print("All new cheers must have been previously downloaded. Initating new request for cheers.")
                self.getNewCheers()
            }
        }
    }
    
    func setAndCheckNewCheers() {
        coreCheers = cheerStore.coreCheers
        // if all new cheers were duplicates, do another try
        if coreCheers.count == 0 {
            print("All new cheers must have been duplicates. Initating new request for cheers.")
            getNextCheer()
        } else {
            downloadAndSetImage() {}
        }
    }
    
    func downloadAndSetImage(completionHandler: @escaping () -> Void) {
        guard coreCheers.count > nextPhotoIndex else {
            print("\(coreCheers.count) cheers loaded. There's no cheer at index \(nextPhotoIndex).")
            return
        }
        
        webClient.downloadImage(url: coreCheers[nextPhotoIndex]
            .value(forKey: "url") as! String) { success, data in
                if success {
                    DispatchQueue.main.async {
                        if let data = data {
                            self.imageView.image = UIImage(data: data)
                        }
                        self.titleLabel.text = self.coreCheers[self.nextPhotoIndex].value(forKey: "title") as? String
                        self.coreCheers[self.nextPhotoIndex].setValue(NSNumber(value: true), forKey: "seen")
                        self.cheerStore.saveCheers()
                        self.nextPhotoIndex = self.nextPhotoIndex + 1
                        self.enableUI(true)
                    }
                    completionHandler()
                } else {
                    self.enableUI(true)
                    return
                }
        }
    }
    
    // MARK: - REDDIT METHODS
    
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
        svc.dismiss(animated: true, completion: nil)
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

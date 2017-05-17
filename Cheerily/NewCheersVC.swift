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
    let webClient = WebClient.sharedInstance()
    let cheerStore = CheerStore.sharedInstance()
    var coreCheers: [NSManagedObject] = []
    var nextPhotoIndex = 0
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var moarButton: UIButton!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var mySavesButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    @IBAction func saveButtonPressed(_ sender: Any) {
        
    }
    
    @IBAction func getNewPressed(_ sender: Any) {
        getNextCheer()
    }
    
    func getNextCheer() {
        enableUI(false)
        if coreCheers.count < 1 {
            webClient.getNewAwws(triedRenewingToken: false) {
                self.setAndCheckNewCheers()
            }
        } else if coreCheers.count > nextPhotoIndex {
            downloadAndSetImage() {
                if (self.coreCheers.count - self.nextPhotoIndex) < 5 {
                    print("Last pictures coming up. Will try to get more.")
                    self.getNewCheers()
                }
            }
        } else {
            print("Something went wrong and there are no more pictures. Woops.")
            Helper.displayAlertOnMain("There was an error. Please restart app.")
        }
    }
    
    func getNewCheers() {
        webClient.getNewAwws(triedRenewingToken: false) {
            self.coreCheers = self.cheerStore.coreCheers
            self.nextPhotoIndex = 0
            // if all new cheers were duplicates, do another try
            if self.coreCheers.count == 0 {
                print("All new cheers must have been duplicates. Initating new request for cheers.")
                self.getNewCheers()
            }
        }
    }
    
    func setAndCheckNewCheers() {
        self.coreCheers = self.cheerStore.coreCheers
        // if all new cheers were duplicates, do another try
        if self.coreCheers.count == 0 {
            print("All new cheers must have been duplicates. Initating new request for cheers.")
            self.getNextCheer()
        } else {
            self.downloadAndSetImage() {}
        }
    }
    
    func downloadAndSetImage(completionHandler: @escaping () -> Void) {
        guard coreCheers.count > nextPhotoIndex else {
            print("\(coreCheers.count) cheers loaded. There's no cheer at index \(nextPhotoIndex).")
            return
        }
        
        webClient.downloadImage(url: coreCheers[nextPhotoIndex]
            .value(forKey: "url") as! String) { data in
                DispatchQueue.main.async {
                    self.imageView.image = UIImage(data: data)
                    self.titleLabel.text = self.coreCheers[self.nextPhotoIndex].value(forKey: "title") as? String
                    self.coreCheers[self.nextPhotoIndex].setValue(NSNumber(value: true), forKey: "seen")
                    self.cheerStore.saveCheers()
                    self.nextPhotoIndex = self.nextPhotoIndex + 1
                    self.enableUI(true)
                }
            completionHandler()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(userHasAuthorized), name: NSNotification.Name(rawValue: kCloseSafariViewControllerNotification), object: nil)
        cheerStore.loadCoreCheers()
        self.coreCheers = cheerStore.coreCheers
        checkToken()
    }
    
    func checkToken() {
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
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        navigationController?.navigationBar.isHidden = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func enableUI(_ enabled: Bool) {
        moarButton.isEnabled = enabled
        saveButton.isEnabled = enabled
        mySavesButton.isEnabled = enabled
        if enabled {
            imageView.isHidden = false
            activityIndicator.isHidden = true
            activityIndicator.stopAnimating()
        } else {
            imageView.isHidden = true
            activityIndicator.isHidden = false
            activityIndicator.startAnimating()
        }
    }
}

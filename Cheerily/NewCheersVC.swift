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
        if let title = titleLabel.text, let image = imageView.image,
            let data = UIImagePNGRepresentation(image) {
                let newSavedCheer = SavedCheerModel(title: title, imageData: data)
                cheerStore.saveSavedCheer(newSavedCheer)
        } else {
            Helper.displayAlertOnMain("Sorry, we could not save this cheer.")
        }
        
        cheerStore.loadSavedCheers()
        
    }
    
    @IBAction func getNewPressed(_ sender: Any) {
        getNextCheer()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(userHasAuthorized), name: NSNotification.Name(rawValue: kCloseSafariViewControllerNotification), object: nil)
        cheerStore.loadCoreCheers()
        self.coreCheers = cheerStore.coreCheers
        checkRedditToken()
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

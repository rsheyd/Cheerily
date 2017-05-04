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
    var redditUrl = WebClient.sharedInstance().getRedditAuthUrl()
    let cheerStore = CheerStore.sharedInstance()
    var validCheers: [Cheer] = []
    var nextPhotoIndex = 0
    var foundCheers: [NSManagedObject] = []
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBAction func buttonPressed(_ sender: Any) {
        self.loadCoreData()
        print(foundCheers.count)
    }
    
    @IBAction func getNewPressed(_ sender: Any) {
        if validCheers.count < 1 {
            webClient.getNewAwws(triedRenewingToken: false) {
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
    
    func loadCoreData() {
        
        guard let appDelegate =
            UIApplication.shared.delegate as? AppDelegate else {
                return
        }
        
        let managedContext = appDelegate.managedObjectContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "CoreCheer")
        
        do {
            foundCheers = try managedContext.fetch(fetchRequest)
            print("cheers fetched")
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
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

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}


//
//  GetNextCheerVC.swift
//  Cheerily
//
//  Created by Roman Sheydvasser on 5/17/17.
//  Copyright © 2017 RLabs. All rights reserved.
//

import UIKit

extension NewCheersVC {
    
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
}

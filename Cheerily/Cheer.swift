//
//  Cheer.swift
//  Cheerily
//
//  Created by Roman Sheydvasser on 4/29/17.
//  Copyright © 2017 RLabs. All rights reserved.
//

import UIKit
import CoreData

struct Cheer {
    // MARK: Properties
    
    let title: String
    let url: String
    let type: String
    let permalink: String
    let mediaData: Data?
    
    // MARK: Initializers
    
    // construct a Cheer from a dictionary
    init(dictionary: [String:AnyObject]) {
        title = dictionary["data"]?["title"] as! String
        let tempUrl = dictionary["data"]?["url"] as! String
        var tempUrlComponents = URLComponents(string: tempUrl)
        if tempUrlComponents?.scheme == "http" {
            tempUrlComponents?.scheme = "https"
        }
        url = tempUrlComponents!.string!
        
        permalink = dictionary["data"]?["permalink"] as! String
        
        let urlNSString = url as NSString
        type = urlNSString.pathExtension as String
        mediaData = nil
    }
    
    static func cheersFromResults(_ results: [[String:AnyObject]]) -> [Cheer] {
        var cheers = [Cheer]()
        var duplicateCheers = 0
        for result in results {
            let newCheer = Cheer(dictionary: result)
            if alreadySaved(newCheer) {
                duplicateCheers += 1
            } else {
                saveToCoreData(newCheer)
            }
            cheers.append(newCheer)
        }
        print("\(duplicateCheers) duplicate cheers found.")
        return cheers
    }
    
    static func saveToCoreData(_ cheer: Cheer) {
        guard let appDelegate =
            UIApplication.shared.delegate as? AppDelegate else {
                return
        }
        
        let managedContext = appDelegate.managedObjectContext
        let entity = NSEntityDescription.entity(forEntityName: "CoreCheer",
                                                in: managedContext)!
        let coreCheer = NSManagedObject(entity: entity,
                                    insertInto: managedContext)
        
        coreCheer.setValue(cheer.title, forKeyPath: "title")
        coreCheer.setValue(cheer.url, forKeyPath: "url")
        coreCheer.setValue(cheer.permalink, forKeyPath: "permalink")
        coreCheer.setValue(cheer.type, forKeyPath: "type")
        coreCheer.setValue(false, forKeyPath: "seen")
        
        appDelegate.saveContext()
    }
    
    static func alreadySaved(_ newCheer: Cheer) -> Bool {
        let newPermalink = newCheer.permalink
        guard let foundCheers = CheerStore.sharedInstance.loadFromCoreData(entity: "CoreCheer", formatString: "permalink == %@", filterValue: newPermalink) else {
            print("Could not load cheers filtered by permalink.")
            return false
        }
        
        if foundCheers.count > 0 {
            return true
        } else {
            return false
        }
    }
}

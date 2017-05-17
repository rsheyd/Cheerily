//
//  CheerStore.swift
//  Cheerily
//
//  Created by Roman Sheydvasser on 4/30/17.
//  Copyright © 2017 RLabs. All rights reserved.
//

import UIKit
import CoreData

class CheerStore: NSObject {
    
    var cheers = [Cheer]()
    var coreCheers = [NSManagedObject]()
    
    // MARK: Shared Instance
    
    class func sharedInstance() -> CheerStore {
        struct Singleton {
            static var sharedInstance = CheerStore()
        }
        return Singleton.sharedInstance
    }
    
    func loadCoreCheers() {
        if let jpgCheers = loadFromCoreData(entity: "CoreCheer",
                                            formatString: "type == %@ AND seen = \(NSNumber(value: true))",
                                            filterValue: "jpg"){
            print("\(jpgCheers.count) seen/jpg cheers found.")
        }
        if let loadedObjects = loadFromCoreData(entity: "CoreCheer",
                                                formatString: "type == %@ AND seen == \(NSNumber(value: false))",
                                                filterValue: "jpg") {
            coreCheers = loadedObjects
            print("\(coreCheers.count) jpg/non-seen core cheers loaded.")
        } else {
            print("Could not load non-seen/jpg cheers from Core Data.")
        }
    }
    
    func loadFromCoreData(entity: String, formatString: String?,
                          filterValue: String?) -> [NSManagedObject]? {
        var managedObjects: [NSManagedObject] = []
        
        guard let appDelegate =
            UIApplication.shared.delegate as? AppDelegate else {
                print("Could not get appDelegate.")
                return nil
        }
        
        let managedContext = appDelegate.managedObjectContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: entity)
        if let formatString = formatString, let filterValue = filterValue{
            fetchRequest.predicate = NSPredicate(format: formatString, filterValue)
        }
        
        do {
            managedObjects = try managedContext.fetch(fetchRequest)
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        
        return managedObjects
    }
    
    func saveCheers() {
        guard let appDelegate =
            UIApplication.shared.delegate as? AppDelegate else {
                print("Could not get appDelegate.")
                return
        }
        
        appDelegate.saveContext()
    }
}

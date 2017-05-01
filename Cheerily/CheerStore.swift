//
//  CheerStore.swift
//  Cheerily
//
//  Created by Roman Sheydvasser on 4/30/17.
//  Copyright © 2017 RLabs. All rights reserved.
//

import Foundation

class CheerStore: NSObject {
    
    var cheers = [Cheer]()
    
    // MARK: Shared Instance
    
    class func sharedInstance() -> CheerStore {
        struct Singleton {
            static var sharedInstance = CheerStore()
        }
        return Singleton.sharedInstance
    }
}

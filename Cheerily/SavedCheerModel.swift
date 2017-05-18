//
//  SavedCheer.swift
//  Cheerily
//
//  Created by Roman Sheydvasser on 5/17/17.
//  Copyright © 2017 RLabs. All rights reserved.
//

import UIKit
import CoreData

struct SavedCheerModel {
    // MARK: Properties
    
    let title: String
    let imageData: Data
    
    // MARK: Initializers
    
    // construct a Cheer from a dictionary
    init(title: String, imageData: Data) {
        self.title = title
        self.imageData = imageData
    }
}

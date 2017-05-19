//
//  SavedCheerVC.swift
//  Cheerily
//
//  Created by Roman Sheydvasser on 5/18/17.
//  Copyright © 2017 RLabs. All rights reserved.
//

import UIKit

class SavedCheerVC: UIViewController {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    
    var titleText: String?
    var imageData: Data?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        guard let titleText = titleText, let imageData = imageData else {
            print("Title/image data not available.")
            return
        }
        
        imageView.image = UIImage(data: imageData)
        titleLabel.text = titleText
    }
    
}

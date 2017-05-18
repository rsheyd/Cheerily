//
//  MySavesVC.swift
//  Cheerily
//
//  Created by Roman Sheydvasser on 5/10/17.
//  Copyright © 2017 RLabs. All rights reserved.
//

import UIKit

class MySavesVC: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    let savedCheers: [SavedCheer] = []
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return savedCheers.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cheerCell")!
        return cell
    }
}

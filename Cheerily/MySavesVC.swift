//
//  MySavesVC.swift
//  Cheerily
//
//  Created by Roman Sheydvasser on 5/10/17.
//  Copyright © 2017 RLabs. All rights reserved.
//

import UIKit
import CoreData

class MySavesVC: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var savedCheers: [NSManagedObject] = []
    var selectedCheerIndex: Int?
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.rightBarButtonItem = editButtonItem
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cheerCell")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        savedCheers = CheerStore.sharedInstance().loadSavedCheers()
        tableView.reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let savedCheerVC = segue.destination as? SavedCheerVC,
            let selectedIndex = selectedCheerIndex,
            let cheerImageData = savedCheers[selectedIndex].value(forKey: "imageData") as? Data else {
                    print("Segue wrong, index missing, or couldn't load image.")
                return
        }
        
        savedCheerVC.imageData = cheerImageData
        savedCheerVC.titleText = savedCheers[selectedIndex]
            .value(forKey: "title") as? String
    }
    
    // MARK: - UITableViewDataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return savedCheers.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cheerCell", for: indexPath)
        let savedCheer = savedCheers[indexPath.row]
        if let cheerImageData = savedCheer.value(forKey: "imageData") as? Data {
            cell.imageView?.image = UIImage(data: cheerImageData)
        }
        
        cell.textLabel?.text = savedCheer.value(forKey: "title") as? String
        return cell
    }
    
    // MARK: - UITableViewDelegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedCheerIndex = indexPath.row
        performSegue(withIdentifier: "toSavedCheer", sender: self)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            CheerStore.sharedInstance().deleteSavedCheer(savedCheers[indexPath.row])
            savedCheers.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        tableView.setEditing(editing, animated: animated)
    }
}

//
//  VCInsect.swift
//  NatureApp
//
//  Created by Miguel Rangel on 5/7/19.
//  Copyright © 2019 Miguel Rangel. All rights reserved.
//

import UIKit
import Firebase
import FBSDKCoreKit
import FBSDKLoginKit

class VCInsect: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return insects.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // Deque each cell
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellInsects", for: indexPath) as? TVCInsect
        
        cell?.txtName.text = insects[indexPath.row].name
        cell?.txtDescription.text = insects[indexPath.row].description
        cell?.insect = insects[indexPath.row]
        
        // Image load from fireStorage
        let url = NSURL(string: insects[indexPath.row].imageUrl)
        URLSession.shared.dataTask(with: url! as URL, completionHandler:{(data, response, error) in
            
            // Download hit an error
            if error != nil {
                print(error)
                return
            }
            
            DispatchQueue.main.async {
                cell?.imagePhoto.image = UIImage(data: data!)
            }
            
            
        }).resume()
        cell?.imagePhoto.image = UIImage(named: "photo.png")
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Set gloabl animal variable
        globalInsect = insects[indexPath.row]
        
        // Go to the edita animal view
        self.performSegue(withIdentifier: "edit", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // If its editing add the animal reference to be edited
        if segue.identifier == "edit" {
            let destination = segue.destination as? VCInsectInfo
            destination?.insect = globalInsect
        }
    }
    
    @IBAction func buLogOut(_ sender: Any) {
        do {
            try Auth.auth().signOut()
            let loginManager = LoginManager()
            loginManager.logOut()
            
            // Logged out go to login view
            self.performSegue(withIdentifier: "logOut", sender: self)
        } catch let err {
            print(err)
        }
    }
    
    @IBAction func buAdd(_ sender: Any) {
        // Go to the add animal view
        self.performSegue(withIdentifier: "add", sender: self)
    }
    
    @IBOutlet weak var tableInsects: UITableView!
    var insects : [Insect] = []
    var globalInsect : Insect!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Set delegate and datasource to the table view
        tableInsects.delegate = self
        tableInsects.dataSource = self
        
        // Watch for changes in the firebase
        watchForChanges()
    }
    
    func watchForChanges(){
        // Instance database reference
        let refDatabase = Database.database().reference()
        // Get reference to the child insects
        let refInsects = refDatabase.child("insects")
        
        // Observe
        refInsects.observe(.childAdded) { (data) in
            // Add to the list
            let insect = Insect()
            insect.uuid = data.key
            // Convert snapshot to dictionary
            let insectInfo = data.value as? NSDictionary
            insect.name = insectInfo?["name"] as? String
            insect.size = insectInfo?["size"] as? String
            insect.toxicity = insectInfo?["toxicity"] as? String
            insect.imageUrl = insectInfo?["imageUrl"] as? String
            insect.status = insectInfo?["status"] as? String
            insect.description = insectInfo?["description"] as? String
            // Add to the list
            self.insects.append(insect)
            self.tableInsects.reloadData()
            
        }
        
        // Observe
        refInsects.observe(.childChanged) { (data) in
            // Update item
            for insect in self.insects {
                if insect.uuid == data.key {
                    let insectInfo = data.value as? NSDictionary
                    insect.name = insectInfo?["name"] as? String
                    insect.size = insectInfo?["size"] as? String
                    insect.toxicity = insectInfo?["toxicity"] as? String
                    insect.imageUrl = insectInfo?["imageUrl"] as? String
                    insect.status = insectInfo?["status"] as? String
                    insect.description = insectInfo?["description"] as? String
                    // Reload the list
                    self.tableInsects.reloadData()
                    // Stop the function
                    return
                }
            }
        }
        
        // Observe
        refInsects.observe(.childRemoved) { (data) in
            // Remove item
            var index = 0
            for insect in self.insects {
                if insect.uuid == data.key {
                    self.insects.remove(at: index)
                    // Reload the list
                    self.tableInsects.reloadData()
                    // Stop the function
                    return
                }
                index  = index + 1
            }
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

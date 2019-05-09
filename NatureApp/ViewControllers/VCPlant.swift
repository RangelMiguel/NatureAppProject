//
//  VCPlant.swift
//  NatureApp
//
//  Created by Miguel Rangel on 5/7/19.
//  Copyright © 2019 Miguel Rangel. All rights reserved.
//

import UIKit
import Firebase
import FBSDKLoginKit
import FBSDKCoreKit

class VCPlant: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return plants.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // Deque each cell
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellPlants", for: indexPath) as? TVCPlant
        
        cell?.txtName.text = plants[indexPath.row].name
        cell?.txtDescription.text = plants[indexPath.row].description
        cell?.plant = plants[indexPath.row]
        
        // Image load from fireStorage
        let url = NSURL(string: plants[indexPath.row].imageUrl)
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
        globalPlant = plants[indexPath.row]
        
        // Go to the edita animal view
        self.performSegue(withIdentifier: "edit", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // If its editing add the animal reference to be edited
        if segue.identifier == "edit" {
            let destination = segue.destination as? VCPlantInfo
            destination?.plant = globalPlant
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
    
    @IBOutlet weak var tablePlants: UITableView!
    var plants : [Plant] = []
    var globalPlant : Plant!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Set delegate and datasource to the table view
        tablePlants.delegate = self
        tablePlants.dataSource = self
        
        // Watch for changes in the firebase
        watchForChanges()
    }
    
    func watchForChanges(){
        // Instance database reference
        let refDatabase = Database.database().reference()
        // Get reference to the child plants
        let refPlants = refDatabase.child("plants")
        
        // Observe
        refPlants.observe(.childAdded) { (data) in
            // Add to the list
            let plant = Plant()
            plant.uuid = data.key
            // Convert snapshot to dictionary
            let plantInfo = data.value as? NSDictionary
            plant.name = plantInfo?["name"] as? String
            plant.type = plantInfo?["type"] as? String
            plant.hazards = plantInfo?["hazards"] as? String
            plant.imageUrl = plantInfo?["imageUrl"] as? String
            plant.statuts = plantInfo?["status"] as? String
            plant.description = plantInfo?["description"] as? String
            // Add to the list
            self.plants.append(plant)
            self.tablePlants.reloadData()
            
        }
        
        // Observe
        refPlants.observe(.childChanged) { (data) in
            // Update item
            for plant in self.plants {
                if plant.uuid == data.key {
                    let plantInfo = data.value as? NSDictionary
                    plant.name = plantInfo?["name"] as? String
                    plant.type = plantInfo?["type"] as? String
                    plant.hazards = plantInfo?["hazards"] as? String
                    plant.imageUrl = plantInfo?["imageUrl"] as? String
                    plant.statuts = plantInfo?["status"] as? String
                    plant.description = plantInfo?["description"] as? String
                    // Reload the list
                    self.tablePlants.reloadData()
                    // Stop the function
                    return
                }
            }
        }
        
        // Observe
        refPlants.observe(.childRemoved) { (data) in
            // Remove item
            var index = 0
            for plant in self.plants {
                if plant.uuid == data.key {
                    self.plants.remove(at: index)
                    // Reload the list
                    self.tablePlants.reloadData()
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

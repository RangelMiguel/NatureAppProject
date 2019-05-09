//
//  VCAnimal.swift
//  NatureApp
//
//  Created by Miguel Rangel on 5/7/19.
//  Copyright © 2019 Miguel Rangel. All rights reserved.
//

import UIKit
import Firebase
import FBSDKCoreKit
import FBSDKLoginKit

class VCAnimal: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return animals.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // Deque each cell
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellAnimal", for: indexPath) as? TVCAnimal
        
        cell?.lblName.text = animals[indexPath.row].name
        cell?.txtDescription.text = animals[indexPath.row].description
        cell?.animal = animals[indexPath.row]
        
        // Image load from fireStorage
        let url = NSURL(string: animals[indexPath.row].imageUrl)
        URLSession.shared.dataTask(with: url! as URL, completionHandler:{(data, response, error) in
            
            // Download hit an error
            if error != nil {
                print(error)
                return
            }
            
            DispatchQueue.main.async {
                cell?.photoImage.image = UIImage(data: data!)
            }
            
            
        }).resume()
        cell?.photoImage.image = UIImage(named: "photo.png")
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Set gloabl animal variable
        globalAnimal = animals[indexPath.row]
        
        // Go to the edita animal view
        self.performSegue(withIdentifier: "edit", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // If its editing add the animal reference to be edited
        if segue.identifier == "edit" {
            let destination = segue.destination as? VCAnimalInfo
            destination?.animal = globalAnimal
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
    
    
    @IBOutlet weak var tableAnimals: UITableView!
    var animals : [Animal] = []
    var globalAnimal : Animal!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Set delegate and datasource to the table view
        tableAnimals.delegate = self
        tableAnimals.dataSource = self
        
        // Watch for changes in the firebase
        watchForChanges()
    }
    
    func watchForChanges(){
        // Instance database reference
        let refDatabase = Database.database().reference()
        // Get reference to the child animals
        let refAnimals = refDatabase.child("animals")
        
        // Observe
        refAnimals.observe(.childAdded) { (data) in
            // Add to the list
            let animal = Animal()
            animal.uuid = data.key
            // Convert snapshot to dictionary
            let animalInfo = data.value as? NSDictionary
            animal.name = animalInfo?["name"] as? String
            animal.clasification = animalInfo?["clasification"] as? String
            animal.habitat = animalInfo?["habitat"] as? String
            animal.status = animalInfo?["status"] as? String
            animal.description = animalInfo?["description"] as? String
            animal.imageUrl = animalInfo?["imageUrl"] as? String
            // Add to the list
            self.animals.append(animal)
            self.tableAnimals.reloadData()
            
        }
        
        // Observe
        refAnimals.observe(.childChanged) { (data) in
            // Update item
            for animal in self.animals {
                if animal.uuid == data.key {
                    let animalInfo = data.value as? NSDictionary
                    animal.name = animalInfo?["name"] as? String
                    animal.clasification = animalInfo?["clasification"] as? String
                    animal.habitat = animalInfo?["habitat"] as? String
                    animal.status = animalInfo?["status"] as? String
                    animal.description = animalInfo?["description"] as? String
                    animal.imageUrl = animalInfo?["imageUrl"] as? String
                    // Reload the list
                    self.tableAnimals.reloadData()
                    // Stop the function
                    return
                }
            }
        }
        
        // Observe
        refAnimals.observe(.childRemoved) { (data) in
            // Remove item
            var index = 0
            for animal in self.animals {
                if animal.uuid == data.key {
                    self.animals.remove(at: index)
                    // Reload the list
                    self.tableAnimals.reloadData()
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

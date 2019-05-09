//
//  VCInsectInfo.swift
//  NatureApp
//
//  Created by Miguel Rangel on 5/7/19.
//  Copyright © 2019 Miguel Rangel. All rights reserved.
//

import UIKit
import Firebase

class VCInsectInfo: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    
    @IBAction func buBack(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func buSave(_ sender: Any) {
        // Check if its adding or editing
        if insect != nil {
            // Editing
            addInsect(isEdit: true)
        } else {
            // Adding
            addInsect(isEdit: false)
        }
    }
    
    @IBAction func buDelete(_ sender: Any) {
        // Obtain reference to the database
        let refDatabase = Database.database().reference()
        // Obtain reference to the animals child
        let refInsects = refDatabase.child("insects")
        // Obtain reference to the child to delete
        let refInsect = refInsects.child(insect.uuid)
        // Delete
        refInsect.removeValue()
        // Go back to the listing of animals
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBOutlet weak var imagePhoto: UIImageView!
    @IBOutlet weak var txtName: UITextField!
    @IBOutlet weak var txtToxicity: UITextField!
    @IBOutlet weak var txtSize: UITextField!
    @IBOutlet weak var txtStatus: UITextField!
    @IBOutlet weak var txtDescription: UITextView!
    @IBOutlet weak var buDelete: UIButton!
    var insect: Insect!
    
    @objc func handleImage(){
        let picker = UIImagePickerController()
        
        picker.delegate = self
        picker.allowsEditing = true
        
        present(picker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        var selectedImageFromPicker: UIImage?
        
        if let editedImage = info[.editedImage] as? UIImage {
            selectedImageFromPicker = editedImage
        } else if let originalImage = info[.originalImage] as? UIImage {
            selectedImageFromPicker = originalImage
        }
        
        if let selectedImage = selectedImageFromPicker {
            imagePhoto.image = selectedImage
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        print("Canceled picker")
        dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Check if its editing or no
        if insect == nil {
            // No editing
            buDelete.isHidden = true
        } else {
            // Editing set info
            txtName.text = insect.name
            txtToxicity.text = insect.toxicity
            txtSize.text = insect.size
            txtStatus.text = insect.status
            txtDescription.text = insect.description
            // Retrieve the image from FireStorage
            let url = NSURL(string: insect.imageUrl)
            URLSession.shared.dataTask(with: url! as URL, completionHandler:{(data, response, error) in
                
                // Download hit an error
                if error != nil {
                    print(error)
                    return
                }
                
                DispatchQueue.main.async {
                    self.imagePhoto.image = UIImage(data: data!)
                }
                
                
            }).resume()
        }
        
        // Enable interaction with the image
        imagePhoto.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleImage)))
        imagePhoto.isUserInteractionEnabled = true
        // Do any additional setup after loading the view.
    }
    
    func addInsect(isEdit:Bool){
        // Obtain a reference to the database
        let refDatabase = Database.database().reference()
        // Obtain a reference to the child plants
        let refInsects = refDatabase.child("insects")
        var refInsect:DatabaseReference!
        // Check if is editing
        if isEdit {
            // Get reference
            refInsect = refInsects.child(insect.uuid)
        } else {
            // New reference
            refInsect = refInsects.childByAutoId()
        }
        
        // Obtain the data to be inserted
        let name = txtName.text!
        let toxicity = txtToxicity.text!
        let size = txtSize.text!
        let status = txtStatus.text!
        let description = txtDescription.text!
        
        // Upload the image to firebase
        let imageName = NSUUID().uuidString
        let refStorage = Storage.storage().reference().child("insect_photos").child("\(imageName).png")
        
        if let uploadData = self.imagePhoto.image!.pngData() {
            
            refStorage.putData(uploadData, metadata: nil) { (metadata, error) in
                
                if error != nil {
                    print(error!)
                    return
                }
                
                refStorage.downloadURL(completion: { (url, error) in
                    
                    if error != nil {
                        print(error!)
                        return
                    }
                    
                    if let imageUrl = url?.absoluteString {
                        
                        // Image uploaded insert the animal to database
                        let values = ["name": name,
                                      "toxicity": toxicity,
                                      "size": size,
                                      "status": status,
                                      "description": description,
                                      "imageUrl": imageUrl
                        ]
                        
                        refInsect.updateChildValues(values
                            , withCompletionBlock: { (error, ref) in
                                
                                if error != nil {
                                    print(error!)
                                    return
                                }
                                
                                // Animal added
                                self.dismiss(animated: true, completion: nil)
                        })
                        
                    }
                    
                })
                
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

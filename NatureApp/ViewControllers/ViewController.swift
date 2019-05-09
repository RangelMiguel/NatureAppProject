//
//  ViewController.swift
//  NatureApp
//
//  Created by Miguel Rangel on 5/7/19.
//  Copyright © 2019 Miguel Rangel. All rights reserved.
//

import UIKit
import FBSDKLoginKit
import FBSDKCoreKit
import Firebase

class ViewController: UIViewController, LoginButtonDelegate {
    
    // When a login occurs
    func loginButton(_ loginButton: FBLoginButton, didCompleteWith result: LoginManagerLoginResult?, error: Error?) {
        if error == nil {
            // Check if the user cancel the loggin
            if result?.isCancelled ?? false {
                print("Cancelled")
                return
            }
            // If there wasnt any errors start the auth with firebase
            let credential = FacebookAuthProvider.credential(withAccessToken: AccessToken.current!.tokenString)
            Auth.auth().signInAndRetrieveData(with: credential) { (authResult, error) in
                if let error = error {
                    print(error.localizedDescription)
                    return
                }
                // No errors - User signed in
                // Goto the next vieew
                self.performSegue(withIdentifier: "segueMain", sender: self)
                func prepareForSegue(segue: UIStoryboardSegue!, sender: AnyObject!) {
                    if segue.identifier == "segueMain" {
                        
                    }
                }
            }
        } else {
                print(error?.localizedDescription)
        }
    }
    
    func loginButtonDidLogOut(_ loginButton: FBLoginButton) {
        print("Logged out")
    }
    

    @IBOutlet weak var loginButton: FBLoginButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Assign delegate to the login button
        loginButton.delegate = self
        loginButton.readPermissions = ["email"]
    }


}


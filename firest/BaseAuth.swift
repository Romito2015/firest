//
//  BaseAuth.swift
//  firest
//
//  Created by Roma Chopovenko on 12/2/17.
//  Copyright © 2017 Roma Chopovenko. All rights reserved.
//

import UIKit
import FBSDKLoginKit
import Firebase

class BaseAuth: UIViewController {
    
    func getFacebookUserData() -> [String : String]? {
        var user: [String : String]?
        FBSDKGraphRequest.init(graphPath: "/me", parameters: ["fields":"id, name, email"]).start { (connection, result, err) in
            if err != nil {
                print("Failed to start graph request: ", err ?? "")
            }
            if let resultDict = result as? [String : String] {
                user = resultDict
            }
        }
        print(user ?? "")
        return user
    }
    
    func go2Main(){
        self.present(AppDelegate.getVC(withId: "mainVC"), animated: true, completion: { })
    }
    
    func updateFIRDatabase(withUser user: User?, userName: String? = nil) {
        var theName = userName
        if let displayName = user?.displayName {
            theName = displayName
        }
        
        guard let uid = user?.uid, let name = theName, let email = user?.email else {
            print("No UID")
            return
        }
        let ref = Database.database().reference(fromURL: Constants.firebaseReference)
        let usersRef = ref.child("users").child(uid)
        let values = ["name" : name, "email" : email]
        usersRef.updateChildValues(values, withCompletionBlock: { (err, ref) in
            
            if err != nil {
                print(err ?? "Error")
            } else {
                self.go2Main()
            }
            
            print ("Succesfully added new user to firebase DB")
        })
    }
    
}

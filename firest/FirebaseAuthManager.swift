//
//  FirebaseAuthManager.swift
//  firest
//
//  Created by Roma Chopovenko on 12/28/17.
//  Copyright © 2017 Roma Chopovenko. All rights reserved.
//

import Foundation
import Firebase

protocol FirebaseAuthManager {
    func createUser(withEmail email: String, password: String) ->()
    func forgotPassword(withEmail: String) -> ()
}

class FirebaseAuthManagerImp: FirebaseAuthManager {
    
    func createUser(withEmail email: String, password: String) {
        Auth.auth().createUser(withEmail: email, password: password) { (user, error) in
            //implement here
        }
    }
    
    func forgotPassword(withEmail email: String) {
        Auth.auth().sendPasswordReset(withEmail: email) { (error) in
            if error != nil {
                print("ForgotPWD ERROR: \(error?.localizedDescription ?? "*No description*")")
            }
        }
    }
    
    
    
    
}



















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
    
    func registerUser(with email: String, password: String, completion: @escaping AuthResultCallback) ->()
    
    func loginUser(with email: String, password: String, completion: @escaping AuthResultCallback) -> ()
    
    func forgotPassword(with email: String, completion: @escaping ErrorCompletion) -> ()
}

class FirebaseAuthManagerImp: FirebaseAuthManager {
    
    func loginUser(with email: String, password: String, completion: @escaping AuthResultCallback) {
        let credential = EmailAuthProvider.credential(withEmail: email, password: password)
        
        Auth.auth().signIn(with: credential) { (user, error) in
            completion(user, error)
        }
    }
    
    func registerUser(with email: String, password: String, completion: @escaping AuthResultCallback) ->() {
        Auth.auth().createUser(withEmail: email, password: password) { (user, error) in
            completion(user, error)
        }
        
    }
    
    func forgotPassword(with email: String, completion: @escaping ErrorCompletion) -> () {
        Auth.auth().sendPasswordReset(withEmail: email) { (error) in
            completion(error)
            if error != nil {
                print("ForgotPWD ERROR: \(error?.localizedDescription ?? "*No description*")")
            }
        }
    }
    
    
    
    
}



















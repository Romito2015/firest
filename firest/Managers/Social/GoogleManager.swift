//
//  GoogleManager.swift
//  firest
//
//  Created by Roma Chopovenko on 1/9/18.
//  Copyright © 2018 Roma Chopovenko. All rights reserved.
//

import UIKit
import GoogleSignIn

protocol GoogleManager {
    static func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!, didSuccess: @escaping successCompletion <Any>, didFail: @escaping failCompletion)
}

class GoogleManagerImp: GoogleManager {
    static func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!, didSuccess: @escaping successCompletion <Any>, didFail: @escaping failCompletion) {
        
        func handleError(error: Error?) {
            if let loginError = error {
                didFail(loginError)
            }
        }
        
        //MARK: GOOGLE
        if error != nil {
            handleError(error: error)
            return
        }
        
        guard let idToken = user.authentication.idToken,
            let accessToken = user.authentication.accessToken else {
                let error: Error = createError(withTitle: "Google idToken or accessToken not found.", domain: "Google SignIn")
                handleError(error: error)
                return
        }
        //MARK: FIREBASE AUTH
        FirebaseAuthManagerImp.loginUser(withGoogleIdToken: idToken, accessToken: accessToken) { (firebaseUser, error) in
            if error != nil {
                handleError(error: error)
                return
            }
            //MARK: FIREBASE DB
            FirebaseDBManagerImp.updateData(forUser: firebaseUser, completion: { (error, DBReference) in
                if error != nil {
                    handleError(error: error)
                    return
                }
                
                let userC: UserC = UserC(uid: user.userID, email: user.profile.email, userProfile: nil)
                didSuccess(userC)
            })
        }
    }
}



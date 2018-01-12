//
//  LoginProvider.swift
//  firest
//
//  Created by Roma Chopovenko on 12/30/17.
//  Copyright © 2017 Roma Chopovenko. All rights reserved.
//

import UIKit
//import FBSDKLoginKit

struct UserC {
    let uid: String?
    let email: String?
    let userProfile: [String : Any?]?
}

struct LoginUser {
    let email: String
    let password: String
    func isValid() -> Bool {
        return email != "" && password != ""
    }
}

protocol LoginProviderDelegate {
    func loginProvider(loginProvider: LoginProvider, didSucceed user: UserC)
    func loginProvider(loginProvider: LoginProvider, didError error: Error)
}

enum LoginProvider {
    case Facebook
    case Twitter
    case Email(LoginUser)
    case None
    
    func login(delegate: LoginProviderDelegate) {
        switch self {
        case .Facebook: loginWithFacebook(delegate: delegate, vc: delegate as! UIViewController)
            break
        case .Twitter: loginWithTwitter(delegate: delegate, vc: delegate as! UIViewController)
            break
        case let .Email(user) where !user.isValid(): loginWithEmail(email: user.email, password: user.password, delegate: delegate)
            break
        case let .Email(user) where user.isValid(): print("No email or password")
            break
        default:
            break
        }
    }
    
//    static var emailHelper: EmailPasswordAuthHelper()
    
    //MARK: 🎭 Facebook
    func loginWithFacebook(delegate: LoginProviderDelegate, vc: UIViewController) {
        FacebookManagerImp.login(withDelegateVC: vc, didSuccess: { (facebookUser) in
            guard let fbToken =  FacebookManagerImp.fbAccessToken else {
                let error: Error = createError(withTitle: "No Facebook AccessToken found", domain: "FacebookManager")
                self.handleError(forDelegate: delegate, error: error)
                return
            }
            
            FirebaseAuthManagerImp.loginUser(withFacebookAccessToken: fbToken.tokenString, completion: { (firebaseUser, error) in 
                if error != nil {
                    self.handleError(forDelegate: delegate, error: error)
                    return
                }
                
                FirebaseDBManagerImp.updateData(forUser: firebaseUser, completion: { (error, DBReference) in
                    if error != nil {
                        self.handleError(forDelegate: delegate, error: error)
                        return
                    }
                    
                    delegate.loginProvider(loginProvider: self, didSucceed: facebookUser as! UserC)
                    return
                })
            })
            
        }) { (error) in
            self.handleError(forDelegate: delegate, error: error)
        }

    }
    
    func handleError(forDelegate loginDelegate: LoginProviderDelegate, error: Error?) {
        if let loginError = error {
            loginDelegate.loginProvider(loginProvider: self, didError: loginError)
        }
    }
    //MARK: 🐦 Twitter
    func loginWithTwitter(delegate: LoginProviderDelegate, vc: UIViewController) {

        //MARK: TWITTER
        TwitterManagerImp.login(withDelegateVC: vc, didSuccess: { (token, secret) in
            //MARK: FIREBASE AUTH
            FirebaseAuthManagerImp.loginUser(withTwitterAccessToken: token, secret: secret, completion: { (firebaseUser, error) in
                if error != nil {
                    self.handleError(forDelegate: delegate, error: error)
                    return
                }
                //MARK: FIREBASE DB
                FirebaseDBManagerImp.updateData(forUser: firebaseUser, completion: { (error, DBReference) in
                    if error != nil {
                        self.handleError(forDelegate: delegate, error: error)
                        return
                    }
                    guard let firUser = firebaseUser else {
                        let error: Error = createError(withTitle: "Failed to retrieve user from Firebse", domain: "LoginFlow")
                        self.handleError(forDelegate: delegate, error: error)
                        return
                    }
                    let user: UserC = UserModelAdapter.getUserC(fromFirebaseUser: firUser)
                    delegate.loginProvider(loginProvider: self, didSucceed: user)
                    return
                })
            })
        }) { (error) in
            self.handleError(forDelegate: delegate, error: error)
        }
    }
    
    //MARK: 📧 Email
    func loginWithEmail(email: String, password: String, delegate: LoginProviderDelegate) {

    }
    
}

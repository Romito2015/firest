//
//  FacebookManager.swift
//  firest
//
//  Created by Roma Chopovenko on 12/29/17.
//  Copyright © 2017 Roma Chopovenko. All rights reserved.
//

import UIKit

import FBSDKLoginKit
import Firebase

protocol FacebookManager {
    static var fbLoginManager: FBSDKLoginManager { get }
    static var fbPermissions: [String] { get }
    static var fbAccessToken: FBSDKAccessToken? { get }
    static func login(withDelegateVC delegate: UIViewController, didSuccess: @escaping successCompletion<Any>, didFail: @escaping failCompletion)
    static func logout()
}

class FacebookManagerImp: FacebookManager {
    
    static var fbLoginManager = FBSDKLoginManager()
    static var fbPermissions: [String] = ["public_profile", "email", "user_friends"]
    static var fbAccessToken: FBSDKAccessToken? = FBSDKAccessToken.current()
    
    static func login(withDelegateVC delegate: UIViewController, didSuccess: @escaping (Any) -> (), didFail: @escaping (Error) -> ()) {
        self.fbLoginManager.logIn(withReadPermissions: self.fbPermissions, from: delegate) { (result, error) in
            
            if let theError = error {
                didFail(theError)
                return
            }
            
            if self.fbAccessToken != nil {
                let request: FBSDKGraphRequest = FBSDKGraphRequest(graphPath: "me", parameters: ["fields":"id,name,email"])
                request.start(completionHandler: { (connection, result, error) in
                    if let theError = error {
                        didFail(theError)
                        return
                    }
                    
                    if let fields = result as? [String:Any],
                        let id = fields["id"] as? String,
                        let email = fields["email"] as? String {
                        
                        let userProfile = ["name" : fields["name"]]
                        let user: UserC = UserC(uid: id, email: email, userProfile: userProfile)
                        didSuccess(user)
                        return
                    }
                })
            }
            
        }
    }
    
    static func logout() {
        if self.fbAccessToken != nil {
            self.fbLoginManager.logOut()
            return
        }
    }
    
    
    
}

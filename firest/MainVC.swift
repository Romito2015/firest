//
//  MainViewController.swift
//  firest
//
//  Created by Roma Chopovenko on 11/28/17.
//  Copyright © 2017 Roma Chopovenko. All rights reserved.
//

import UIKit
import Firebase
import GoogleSignIn
import TwitterKit

class MainVC: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        FirebaseAuthManagerImp.printAuthProviders()
    }
    
    @IBAction func logoutAction(_ sender: UIButton) {
        FirebaseAuthManagerImp.logout(didSuccess: {
            guard let window = UIApplication.shared.keyWindow else { return }
            if window.rootViewController is MainVC {
                self.dismiss(animated: true, completion: { })
            } else {
                window.rootViewController = AppDelegate.getVC(withId: "loginNavVC")
            }
            FacebookManagerImp.logout()
            TwitterManagerImp.logout()
            self.logoutGoogle()
        }) { (error) in
            if let theError = error {
                print(theError.localizedDescription)
            }
        }
    }
    
    
    func logoutGoogle() {
        if GIDSignIn.sharedInstance().currentUser != nil {
            GIDSignIn.sharedInstance().signOut()
        }
    }
    
    @IBAction func linkTwitterAction(_ sender: TWTRLogInButton) {
        sender.logInCompletion = { session, error in
            if (session != nil) {
                print("signed in as \(session?.userName ?? "")");
                guard let token = session?.authToken, let secret = session?.authTokenSecret else {
                    print("Twitter session token & secret not found!")
                    return
                }
                let credentials = TwitterAuthProvider.credential(withToken: token, secret: secret)
                let prevUser = Auth.auth().currentUser
                
                prevUser?.link(with: credentials, completion: { (updatedUser, err) in
                    if err != nil {
                        TwitterManagerImp.logout()
                        print("Failed to link Twitter: ", err?.localizedDescription ?? "")
                        return
                    }
                    print("Updated user: ", updatedUser!)
                })
            } else {
                print("error: \(error?.localizedDescription ?? "")");
            }
        }
    }
    
    
}

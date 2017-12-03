//
//  MainViewController.swift
//  firest
//
//  Created by Roma Chopovenko on 11/28/17.
//  Copyright © 2017 Roma Chopovenko. All rights reserved.
//

import UIKit
import Firebase
import FBSDKLoginKit
import GoogleSignIn
import TwitterKit

class MainVC: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let user = Auth.auth().currentUser
        if let providers: [UserInfo] = user?.providerData {
            var str = "\(providers.count) Auth providers:"
            for provider in providers {
                str += " \(provider.providerID)"
            }
            print(str)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func logoutAction(_ sender: UIButton) {
        let window = UIApplication.shared.keyWindow
        do {
            try Auth.auth().signOut() // Sign out from Firebase
            if window!.rootViewController is MainVC {
                self.dismiss(animated: true, completion: { })
            } else {
                window!.rootViewController = AppDelegate.getVC(withId: "loginNavVC")
            }
            self.logoutFacebook()
            self.logoutGoogle()
            self.logoutTwitter()
        } catch let error {
            print("Logout Catched error: \(error.localizedDescription)")
        }
    }
    
    func logoutFacebook(){
        if FBSDKAccessToken.current() != nil {
            FBSDKLoginManager().logOut()
            return
        }
    }
    
    func logoutGoogle() {
        if GIDSignIn.sharedInstance().currentUser != nil {
            GIDSignIn.sharedInstance().signOut()
        }
    }
    
    func logoutTwitter() {
        let store = Twitter.sharedInstance().sessionStore
        if let userID = store.session()?.userID {
            store.logOutUserID(userID)
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
                        print("Failed to link Twitter")
                        return
                    }
                    print("Updated user: ", updatedUser!)
                    print("1111")
                })
            } else {
                print("error: \(error?.localizedDescription ?? "")");
            }
        }
    }
    
    
}

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
    
}

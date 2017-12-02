//
//  SocialLoginVC.swift
//  firest
//
//  Created by Roma Chopovenko on 12/2/17.
//  Copyright © 2017 Roma Chopovenko. All rights reserved.
//
import UIKit
import Firebase
import FBSDKLoginKit

class SocialLoginVC: BaseAuth {
    
    @IBOutlet weak var defaultFBLoginButton: FBSDKLoginButton!
    @IBOutlet weak var customFBLoginButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.configureFacebook(button: self.defaultFBLoginButton)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
    }
    
    @IBAction func customFBLoginAction(_ sender: UIButton) {
        if FBSDKAccessToken.current() != nil {
            print("You are already logged in to Facebook!")
            return
        }
        FBSDKLoginManager().logIn(withReadPermissions: ["email"], from: self) { (result, err) in
            if err != nil {
                print("Custom FB Login failed: ", err ?? "")
                return
            }
            self.showMyFacebookEmailAddress()
        }
    }
    func configureFacebook(button: FBSDKLoginButton) {
        button.delegate = self
        button.backgroundColor = .clear
        button.readPermissions = ["public_profile", "email", "user_friends"]
    }
    
    func showMyFacebookEmailAddress() {
        let accessToken = FBSDKAccessToken.current()
        guard let accessTokenString = accessToken?.tokenString else { return }
        
        let credentials = FacebookAuthProvider.credential(withAccessToken: accessTokenString)
        Auth.auth().signIn(with: credentials, completion: { (user, error) in
            if error != nil {
                print("Something went wrong with our FB user: ", error ?? "")
                return
            }
            print("🚀 Successfully logged in with our user: ", user ?? "")
            
            if error != nil {
                print(error?.localizedDescription ?? "Register error")
            }
            super.updateFIRDatabase(withUser: user)
        })
    }
    
}

//MARK: 🌎 FBSDKLoginButtonDelegate
extension SocialLoginVC: FBSDKLoginButtonDelegate {
    func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
        if error != nil {
            print(error)
        }
        print("Successfully logged in with Facebook 👍")
        self.showMyFacebookEmailAddress()
    }
    
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
        print("Did logout from Facebook")
    }
}


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
import GoogleSignIn
import TwitterKit

class SocialLoginVC: BaseAuth, GIDSignInUIDelegate {
    
    @IBOutlet weak var defaultFBLoginButton: FBSDKLoginButton!
    @IBOutlet weak var customFBLoginButton: UIButton!
    @IBOutlet weak var defaultGoogleButton: GIDSignInButton!
    @IBOutlet weak var customGoogleButton: UIButton!
    @IBOutlet weak var defaultTwitterButton: TWTRLogInButton!
    @IBOutlet weak var customTwitterButton: UIButton!
    
    var twitterCompletion: TwitterCore.TWTRLogInCompletion?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.configureFacebook(button: self.defaultFBLoginButton)
        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance().delegate = self
        self.setTwitterLoginCompletion()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    func setTwitterLoginCompletion() {
        self.twitterCompletion = { session, error in
            if (session != nil) {
                print("signed in as \(session?.userName ?? "")");
                guard let token = session?.authToken, let secret = session?.authTokenSecret else {
                    print("Twitter session token & secret not found!")
                    return
                }
                let credentials = TwitterAuthProvider.credential(withToken: token, secret: secret)
                Auth.auth().signIn(with: credentials, completion: { (user, err) in
                    if err != nil {
                        print("Firebase login with Twitter failed: ", err ?? "")
                    }
                    super.updateFIRDatabase(withUser: user)
                })
            } else {
                print("error: \(error?.localizedDescription ?? "")");
            }
        }
    }
    
    @IBAction func defaultTwitterAction(_ sender: TWTRLogInButton) {
        if Twitter.sharedInstance().sessionStore.session() != nil {
            print("You are already logged in to Twitter!")
            return
        }
        guard let completion = self.twitterCompletion else {
            print("Twitter login completion has not being set!")
            return
        }
        sender.logInCompletion = completion
    }
    
    @IBAction func customTwitterAction(_ sender: UIButton) {

        if Twitter.sharedInstance().sessionStore.existingUserSessions().count != 0 {
            print("You are already logged in to Twitter!")
            return
        }
        guard let completion = self.twitterCompletion else {
            print("Twitter login completion has not being set!")
            return
        }
        Twitter.sharedInstance().logIn(completion: completion)
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
    
    @IBAction func customGoogleAction(_ sender: UIButton) {
        GIDSignIn.sharedInstance().signIn()
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

//MARK: 🔍 Google SignInDelegate
extension SocialLoginVC: GIDSignInDelegate {
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if let err = error {
            print("Failed to log into Google: ", err)
            return
        }
        
        print("Successfully logged into Google", user)
        
        guard let idToken = user.authentication.idToken else { return }
        guard let accessToken = user.authentication.accessToken else { return }
        let credentials = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: accessToken)
        
        Auth.auth().signIn(with: credentials, completion: { (user, error) in
            if let err = error {
                print("Failed to create a Firebase User with Google account: ", err)
                return
            }
            
            guard let uid = user?.uid else { return }
            super.updateFIRDatabase(withUser: user)
            print("Successfully logged into Firebase with Google", uid)
        })
    }
}


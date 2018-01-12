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
    
    @IBOutlet weak var customFBLoginButton: UIButton!
    @IBOutlet weak var defaultGoogleButton: GIDSignInButton!
    @IBOutlet weak var customGoogleButton: UIButton!
    @IBOutlet weak var customTwitterButton: UIButton!
    
    var loginProvider: LoginProvider = .None
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance().delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    @IBAction func customTwitterAction(_ sender: UIButton) {
        self.loginProvider = .Twitter
        self.loginProvider.login(delegate: self)
    }
    
    @IBAction func customFBLoginAction(_ sender: UIButton) {
        self.loginProvider = .Facebook
        self.loginProvider.login(delegate: self)
    }
    
    @IBAction func customGoogleAction(_ sender: UIButton) {
        GIDSignIn.sharedInstance().signIn()
    }
    
    func handleSuccess(loginProvider: LoginProvider, didSucceed user: UserC) {
        print("User: \(String(describing: user.userProfile)), \(user.email ?? "")")
        super.go2Main()
    }
    func handleFail(loginProvider: LoginProvider, didError error: Error) {
        print("Login error: ", error.localizedDescription)
    }
    
}

//MARK: 🌎 LoginProviderDelegate
extension SocialLoginVC: LoginProviderDelegate {
    func loginProvider(loginProvider: LoginProvider, didSucceed user: UserC) {
        self.handleSuccess(loginProvider: .None, didSucceed: user)
    }
    
    func loginProvider(loginProvider: LoginProvider, didError error: Error) {
        self.handleFail(loginProvider: loginProvider, didError: error)
    }
    
}

//MARK: 🔍 Google SignInDelegate
extension SocialLoginVC: GIDSignInDelegate {

    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        GoogleManagerImp.sign(signIn, didSignInFor: user, withError: error, didSuccess: { (theUser) in
            let user = theUser as! UserC
            self.handleSuccess(loginProvider: .None, didSucceed: user)
        }) { (error) in
            self.handleFail(loginProvider: .None, didError: error)
        }
    }
}

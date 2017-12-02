//
//  ViewController.swift
//  firest
//
//  Created by Roma Chopovenko on 11/27/17.
//  Copyright © 2017 Roma Chopovenko. All rights reserved.
//

import UIKit
import Firebase

class ManualLoginVC: BaseAuth {
    
    @IBOutlet weak var authSC: UISegmentedControl!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var registerButton: UIButton!
    @IBOutlet weak var forgotPwdButton: UIButton!
    
    @IBOutlet weak var nameStackView: UIStackView!
    @IBOutlet weak var forgotPwdStackView: UIStackView!
    
    var isLogin: Bool = false {
        didSet {
            self.nameStackView.isHidden = isLogin
            self.forgotPwdStackView.isHidden = !isLogin
            let title = self.authSC.titleForSegment(at: self.authSC.selectedSegmentIndex)
            self.registerButton.setTitle(title, for: .normal)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.isLogin = true
    }
    
    @IBAction func registerAction(_ sender: Any) {
        self.isLogin ? self.performLogin() : self.performRegister()
    }
    @IBAction func authSCAction(_ sender: UISegmentedControl) {
        self.isLogin = sender.selectedSegmentIndex == 0
    }
    
    //MARK: 🔐 Login
    func performLogin() {
        print("LOGIN")
        guard let email = emailTextField.text, let password = passwordTextField.text else {
            print("Cannot Login")
            return
        }
        let credential = EmailAuthProvider.credential(withEmail: email, password: password)
        Auth.auth().signIn(with: credential) { (user, error) in
            if error != nil {
                print(error?.localizedDescription ?? "Login error")
            } else {
                self.go2Main()
            }
        }
    }
    //MARK: 🚀 Register
    func performRegister(){
        print("REGISTER")
        guard let name = nameTextField.text, let email = emailTextField.text, let password = passwordTextField.text else {
            print("Cannot Regiseter")
            return
        }
        
        Auth.auth().createUser(withEmail: email, password: password) {(user, error) in
            if error != nil {
                print(error?.localizedDescription ?? "Register error")
            }
            super.updateFIRDatabase(withUser: user, userName: name)
        }
    }
    
    //MARK: 🏮 Forgot/Reset password
    @IBAction func forgotPwdAction(_ sender: UIButton) {
        guard let email = self.emailTextField.text else {
            print("No email entered")
            return
        }
        Auth.auth().sendPasswordReset(withEmail: email) { (error) in
            if error != nil {
                print("ForgotPWD ERROR: \(error?.localizedDescription ?? "*No description*")")
            }
        }
    }
    
}


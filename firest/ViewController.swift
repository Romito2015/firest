//
//  ViewController.swift
//  firest
//
//  Created by Roma Chopovenko on 11/27/17.
//  Copyright © 2017 Roma Chopovenko. All rights reserved.
//

import UIKit
import Firebase

class ViewController: UIViewController {
    
    @IBOutlet weak var authSC: UISegmentedControl!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var registerButton: UIButton!
    
    var isLogin: Bool = false {
        didSet {
            self.nameStackView.isHidden = isLogin
            let title = self.authSC.titleForSegment(at: self.authSC.selectedSegmentIndex)
            self.registerButton.setTitle(title, for: .normal)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.isLogin = true
    }
    
    @IBOutlet weak var nameStackView: UIStackView!
    @IBAction func registerAction(_ sender: Any) {
        self.isLogin ? self.performLogin() : self.performRegister()
    }
    @IBAction func authSCAction(_ sender: UISegmentedControl) {
        self.isLogin = sender.selectedSegmentIndex == 0
    }
    
    func performLogin() {
        print("LOGIN")
        guard let email = emailTextField.text, let password = passwordTextField.text else {
            print("Cannot Login")
            return
        }
        Auth.auth().signIn(withEmail: email, password: password) { (user, error) in
            if error != nil {
                print(error?.localizedDescription ?? "Login error")
            }
        }
    }
    
    func performRegister(){
        print("REGISTER")
        guard let name = nameTextField.text, let email = emailTextField.text, let password = passwordTextField.text else {
            print("Cannot Regiseter")
            return
        }
        
        Auth.auth().createUser(withEmail: email, password: password) { (user, error) in
            if error != nil {
                print(error?.localizedDescription ?? "Register error")
            }
            
            guard let uid = user?.uid else {
                print("No UID")
                return
            }
            let ref = Database.database().reference(fromURL: "https://firest-dbc22.firebaseio.com/")
            let usersRef = ref.child("users").child(uid)
            let values = ["name" : name, "email" : email]
            usersRef.updateChildValues(values, withCompletionBlock: { (err, ref) in
                
                if err != nil {
                    print(err ?? "Error")
                }
                print ("Succesfully added new user to firebase DB")
            })
        }
    }
    
    
}


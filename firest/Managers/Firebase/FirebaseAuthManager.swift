//
//  FirebaseAuthManager.swift
//  firest
//
//  Created by Roma Chopovenko on 12/28/17.
//  Copyright © 2017 Roma Chopovenko. All rights reserved.
//

import Foundation
import Firebase

struct UserModelAdapter {
    static func getUserC(fromFirebaseUser user: User) -> UserC {
        return UserC(uid: user.uid, email: user.email, userProfile: nil)
    }
}

protocol FirebaseAuthManager {
    static func registerUser(with email: String?, password: String?, completion: @escaping AuthResultCallback) ->()
    static func loginUser(with email: String?, password: String?, completion: @escaping AuthResultCallback) -> ()
    static func loginUser(withFacebookAccessToken accessToken: String, completion: @escaping AuthResultCallback) -> ()
    static func loginUser(withTwitterAccessToken accessToken: String, secret: String, completion: @escaping AuthResultCallback)
    static func loginUser(withGoogleIdToken idToken: String, accessToken: String, completion: @escaping AuthResultCallback)
    static func googleAuthCredential(fromTokenString idToken : String, accessToken: String) -> AuthCredential
    static func forgotPassword(with email: String?, completion: @escaping ErrorCompletion) -> ()
    static func logout(didSuccess: ()->(), didError: @escaping ErrorCompletion)
    static func printAuthProviders()
}

class FirebaseAuthManagerImp: FirebaseAuthManager {
    
    static func loginUser(with email: String?, password: String?, completion: @escaping AuthResultCallback) {
        guard let credential = self.emailAuthCredential(from: email, password: password) else { return }
        self.login(withCredentials: credential) { (user, error) in
            completion(user, error)
        }
    }
    
    static func loginUser(withFacebookAccessToken accessToken: String, completion: @escaping AuthResultCallback) {
        let fbCredentials = self.fbAuthCredential(fromTokenString: accessToken)
        self.login(withCredentials: fbCredentials) { (user, error) in
            completion(user, error)
        }
    }
    
    static func loginUser(withTwitterAccessToken accessToken: String, secret: String, completion: @escaping AuthResultCallback) {
        let twitterCredentials = self.twitterAuthCredential(fromTokenString: accessToken, secret: secret)
        self.login(withCredentials: twitterCredentials) { (user, error) in
            completion(user, error)
        }
    }
    
    static func loginUser(withGoogleIdToken idToken: String, accessToken: String, completion: @escaping AuthResultCallback) {
        let credentials = self.googleAuthCredential(fromTokenString: idToken, accessToken: accessToken)
        self.login(withCredentials: credentials) { (user, error) in
            completion(user, error)
        }
    }
    
    private static func login(withCredentials credentials: AuthCredential, completion: @escaping AuthResultCallback) {
        Auth.auth().signIn(with: credentials) { (user, error) in
            completion(user, error)
        }
    }
    
    static func fbAuthCredential(fromTokenString token: String ) -> AuthCredential {
        let credentials: AuthCredential = FacebookAuthProvider.credential(withAccessToken: token)
        return credentials
    }
    
    static func twitterAuthCredential(fromTokenString token : String, secret: String) -> AuthCredential {
        let credentials: AuthCredential = TwitterAuthProvider.credential(withToken: token, secret: secret)
        return credentials
    }
    
    static func googleAuthCredential(fromTokenString idToken : String, accessToken: String) -> AuthCredential {
        let credentials: AuthCredential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: accessToken)
        return credentials
    }
    
    func twitterAuthCredential(fromToken token: String, secret: String) -> AuthCredential {
        let credentials = TwitterAuthProvider.credential(withToken: token, secret: secret)
        return credentials
    }
    
    static func emailAuthCredential(from email: String?, password: String? ) -> AuthCredential? {
        guard let mail = email, let pwd = password else {
            print("Error: No Email or Password")
            return nil
        }
        let credentials: AuthCredential = EmailAuthProvider.credential(withEmail: mail, password: pwd)
        return credentials
    }
    
    static func registerUser(with email: String?, password: String?, completion: @escaping AuthResultCallback) ->() {
        guard let mail = email, let pwd = password else {
            print("Error: No Email or Password")
            return
        }
        Auth.auth().createUser(withEmail: mail, password: pwd) { (user, error) in
            completion(user, error)
        }
    }
    
    static func forgotPassword(with email: String?, completion: @escaping ErrorCompletion) -> () {
        guard let mail = email else {
            print("Error: No Email")
            return
        }
        Auth.auth().sendPasswordReset(withEmail: mail) { (error) in
            completion(error)
            if let theError = error {
                print("ForgotPWD ERROR: \(theError.localizedDescription)")
            }
        }
    }
    
    static func logout(didSuccess: () -> (), didError: @escaping ErrorCompletion) {
        do {
            try Auth.auth().signOut() // Sign out from Firebase
            didSuccess()
        } catch let error {
            didError(error)
        }
    }
    
    static func printAuthProviders() {
        let user = Auth.auth().currentUser
        if let providers: [UserInfo] = user?.providerData {
            var str = "\(providers.count) Auth providers:"
            for provider in providers {
                str += " \(provider.providerID)"
            }
            print(str)
        }
    }
    
    func linkCurrentUser(withNewCredentials credentials: AuthCredential, didSucces: @escaping (User)->(), didFail: @escaping ErrorCompletion) {
        
        guard let currentUser = Auth.auth().currentUser else {
            print("No current User found")
            return
        }
        currentUser.link(with: credentials) { (newUser, error) in
            if error != nil { didFail(error) }
            if let user = newUser {
                didSucces(user)
            }
        }
        
        
    }

}

//
//  TwitterManager.swift
//  firest
//
//  Created by Roma Chopovenko on 1/7/18.
//  Copyright © 2018 Roma Chopovenko. All rights reserved.
//

import Foundation
import TwitterKit

protocol TwitterManager {
    static var sessionStore: TWTRSessionStore { get }
    static var sessionsCount: Int { get }
    static func login(withDelegateVC delegate: UIViewController, didSuccess: @escaping successTwitterCompletion, didFail: @escaping failCompletion)
    static func logout()
}

class TwitterManagerImp: TwitterManager {
    static var sessionStore: TWTRSessionStore = TWTRTwitter.sharedInstance().sessionStore
    
    static var sessionsCount: Int { return self.sessionStore.existingUserSessions().count }
    
    static func login(withDelegateVC delegate: UIViewController, didSuccess: @escaping successTwitterCompletion, didFail: @escaping failCompletion) {
        TWTRTwitter.sharedInstance().logIn(with: delegate) { session, error in
            if (session != nil) {
                print("Signed in as \(session?.userName ?? "")");
                guard let token = session?.authToken, let secret = session?.authTokenSecret else {
                    let error: Error = createError(withTitle: "Twitter session token & secret not found!", domain: "Twitter Manager")
                    didFail(error)
                    return
                }
                didSuccess(token, secret)
            } else {
                if let theError = error { didFail(theError) }
            }
        }
    }
    
    static func logout() {
        if let userID = self.sessionStore.session()?.userID {
            print("Logged out user with id: ", userID)
            self.sessionStore.logOutUserID(userID)
        }
    }
}

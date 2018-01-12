//
//  FirebaseDBManager.swift
//  firest
//
//  Created by Roma Chopovenko on 12/28/17.
//  Copyright © 2017 Roma Chopovenko. All rights reserved.
//

import Foundation
import Firebase

typealias ErrorCompletion = (Error?) -> ()
typealias DBReferenceCompletion = (Error?, DatabaseReference) -> ()
typealias FirebaseUserCompletion = (User, DatabaseReference) -> ()

fileprivate let firebaseReference = "https://firest-dbc22.firebaseio.com/"

fileprivate struct keys {
    struct user {
        static let name: String = "name"
        static let email: String = "email"
    }
}
enum DBInstanceTable: String {
    case users = "users"
}

protocol FirebaseDBManager {
    static var referenceDB: DatabaseReference { get }
    static func getReference(forInstanceTable tableDB: DBInstanceTable, withUid uid: String) -> DatabaseReference
    static func updateData(forTableDBReference reference: DatabaseReference,
                    withValues values: [String : Any],
                    completion: @escaping DBReferenceCompletion) -> ()
    static func updateData(forUser user: User?, withName userName: String?, completion: @escaping DBReferenceCompletion)
}

class FirebaseDBManagerImp: FirebaseDBManager {
    
    static var referenceDB: DatabaseReference = Database.database().reference(fromURL: firebaseReference)
    
    static func getReference(forInstanceTable tableDB: DBInstanceTable, withUid uid: String) -> DatabaseReference {
        let usersRef: DatabaseReference = referenceDB.child(tableDB.rawValue).child(uid)
        return usersRef
    }
    
    static func updateData(forTableDBReference reference: DatabaseReference, withValues values: [String : Any], completion: @escaping (Error?, DatabaseReference) -> ()) {
        reference.updateChildValues(values) { (error, resultReference) in
            completion(error, resultReference)
        }
    }
    
    static func updateData(forUser user: User?, withName userName: String? = nil, completion: @escaping DBReferenceCompletion) {
        
        var theName = userName
        if let displayName = user?.displayName {
            theName = displayName
        }
        
        guard let uid = user?.uid, let name = theName, let email = user?.email else {
            print("No UID")
            return
        }
        
        let userReference = self.getReference(forInstanceTable: .users, withUid: uid)
        let values = [keys.user.name : name,
                      keys.user.email : email]
        
        self.updateData(forTableDBReference: userReference, withValues: values) { (error, resultReference) in
            completion(error, resultReference)
        }
    }
}

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
    var referenceDB: DatabaseReference { get }
    func getReference(forInstanceTable tableDB: DBInstanceTable, withUid uid: String) -> DatabaseReference
    func updateData(forTableDBReference reference: DatabaseReference,
                    withValues values: [String : Any],
                    completion: @escaping DBReferenceCompletion) -> ()
}

class FirebaseDBManagerImp: FirebaseDBManager {
    
    internal var referenceDB: DatabaseReference = Database.database().reference(fromURL: firebaseReference)
    
    internal func getReference(forInstanceTable tableDB: DBInstanceTable, withUid uid: String) -> DatabaseReference {
        let usersRef: DatabaseReference = referenceDB.child(tableDB.rawValue).child(uid)
        return usersRef
    }
    
    internal func updateData(forTableDBReference reference: DatabaseReference, withValues values: [String : Any], completion: @escaping (Error?, DatabaseReference) -> ()) {
        reference.updateChildValues(values) { (error, resultReference) in
            completion(error, resultReference)
        }
    }
}

extension FirebaseDBManager {
    
    
    
    func updateData(for user: User, with name: String, email: String, completion: @escaping DBReferenceCompletion) {
        
        let userReference = self.getReference(forInstanceTable: .users, withUid: user.uid)
        let values = [keys.user.name : name,
                      keys.user.email : email]
        
        self.updateData(forTableDBReference: userReference, withValues: values) { (error, resultReference) in
            completion(error, resultReference)
        }
    }
}







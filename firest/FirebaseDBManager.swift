//
//  FirebaseDBManager.swift
//  firest
//
//  Created by Roma Chopovenko on 12/28/17.
//  Copyright © 2017 Roma Chopovenko. All rights reserved.
//

import Foundation
import Firebase

fileprivate let firebaseReference = "https://firest-dbc22.firebaseio.com/"
enum DBInstanceTable: String {
    case users = "users"
}

protocol FirebaseDBManager {
    var referenceDB: DatabaseReference { get }
    func getReference(forInstanceTable tableDB: DBInstanceTable, withUid uid: String) -> DatabaseReference
    func updateData(forTableDBReference reference: DatabaseReference, withValues values: [String : Any], completion: @escaping (Error?, DatabaseReference)->()) -> ()
}

class FirebaseDBManagerImp: FirebaseDBManager {
    
    var referenceDB: DatabaseReference = Database.database().reference(fromURL: firebaseReference)
    
    func updateData(forTableDBReference reference: DatabaseReference, withValues values: [String : Any], completion: @escaping (Error?, DatabaseReference) -> ()) {
        reference.updateChildValues(values) { (error, resultReference) in
            completion(error, resultReference)
        }
    }
    
    func getReference(forInstanceTable tableDB: DBInstanceTable, withUid uid: String) -> DatabaseReference {
        let usersRef: DatabaseReference = referenceDB.child(tableDB.rawValue).child(uid)
        return usersRef
    }
    
}

struct FirUser {
    struct keys {
        static let name: String = "name"
        static let email: String = "email"
    }
    
    
    
    
    
}

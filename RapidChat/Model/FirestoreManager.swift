//
//  FirestoreManager.swift
//  RapidChat
//
//  Created by William Chung on 4/25/22.
//

import Foundation
import FirebaseFirestore

// Class to maintain the singleton for user storage in the firestore database
final class FirestoreManager{
    static let shared = FirestoreManager()
    
    let db = Firestore.firestore()
    
    // If we call this code, we can add a user with the given datasets
    public func addUser(with user: User){
        db.collection("users").document(user.email).setData(["name": user.fullName, "username": "", "points": 0, "photoURL": ""])
    }
}

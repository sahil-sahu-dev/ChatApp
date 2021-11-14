//
//  FirebaseManager.swift
//  ChatApp
//
//  Created by Sahil Sahu on 13/11/21.
//

import Foundation
import Firebase

class FirebaseManager {
    
    let auth: Auth
    let storage: Storage
    static let shared = FirebaseManager()
    
    init() {
        FirebaseApp.configure()
        self.auth = Auth.auth()
        self.storage = Storage.storage()
    }
}

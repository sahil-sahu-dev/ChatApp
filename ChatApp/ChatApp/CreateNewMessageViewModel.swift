//
//  CreateNewMessageViewModel.swift
//  ChatApp
//
//  Created by Sahil Sahu on 29/11/21.
//

import Foundation
import SwiftUI


class CreateNewMessageViewModel: ObservableObject {
    
    @Published var users = [ChatUser]()
    @Published var errorMessage = ""
    
    init() {
        fetchAllUsers()
    }
    
    private func fetchAllUsers() {
        FirebaseManager.shared.firestore.collection("users").getDocuments { documentSnapshot, error in
            
            if let error = error {
                self.errorMessage = "Could not fetch all users from firestore \(error.localizedDescription)"
                print("Could not fetch all users from firestore \(error.localizedDescription)")
                return
            }
            
            //we have good data
            
            documentSnapshot?.documents.forEach({ snapshot in
                let data = snapshot.data()
                let uid = data["uid"] as? String ?? ""
                let email = data["email"] as? String ?? ""
                let profileImageUrl = data["profileImageUrl"]  as? String ?? ""
                
                let user = ChatUser(uid: uid, imageProfile: profileImageUrl, email: email)
                if user.uid != FirebaseManager.shared.auth.currentUser?.uid { //do not allow to send message to self user
                    self.users.append(user)
                }
                
            })
            
            self.errorMessage = "fetched all users successfully"
            
        }
    }
}

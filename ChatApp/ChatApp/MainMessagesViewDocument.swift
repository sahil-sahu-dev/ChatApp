//
//  MainMessagesViewDocument.swift
//  ChatApp
//
//  Created by Sahil Sahu on 25/11/21.
//

import Foundation


class MainMessagesViewDocument: ObservableObject {
    
    @Published var chatUser: ChatUser?
    @Published var errorMessage: String = ""
    
    
    init() {
        fetchCurrentUser()
    }
    
    private func fetchCurrentUser() {
        
        guard let user_uid = FirebaseManager.shared.auth.currentUser?.uid else {
            self.errorMessage = "Could not find user uid"
            return
        }
        
        FirebaseManager.shared.firestore.collection("users").document(user_uid).getDocument { snapshot, error in
            
            if let error = error {
                self.errorMessage = "Could not fetch user data \(error)"
                print("Couldnt fetch user ")
            }
            
            guard let data = snapshot?.data() else {
                self.errorMessage = "No data found"
                return
            }
            
            let uid = data["uid"] as? String ?? ""
            let email = data["email"] as? String ?? ""
            let profileImageUrl = data["profileImageUrl"]  as? String ?? ""
            
            self.chatUser = ChatUser(uid: uid, imageProfile: profileImageUrl, email: email)
        }
        
    }
}

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
    @Published var isUserCurrentlyLoggedOut = false
    
    
    init() {
        self.isUserCurrentlyLoggedOut = FirebaseManager.shared.auth.currentUser?.uid == nil ? true : false
        fetchCurrentUser()
    }
    
    private func fetchCurrentUser() {
        
        guard let user_uid = FirebaseManager.shared.auth.currentUser?.uid else {
            self.errorMessage = "Could not find user uid"
            return
        }
        self.errorMessage = "\(user_uid)"
        
        FirebaseManager.shared.firestore.collection("users").document(user_uid).getDocument { snapshot, error in
            
            if let error = error {
               self.errorMessage = "Could not fetch user data \(error)"
                return
            }
            
            
            guard let data = snapshot?.data() else {
                self.errorMessage = "No data found"
                return
            }
            
            self.errorMessage = "Data: \(data.description)"
            
            let uid = data["uid"] as? String ?? ""
            let email = data["email"] as? String ?? ""
            let profileImageUrl = data["profileImageUrl"]  as? String ?? ""
            
            self.chatUser = ChatUser(uid: uid, imageProfile: profileImageUrl, email: email)
            
           // self.errorMessage = self.chatUser!.imageProfile
        }
        
    }
    
    func handleSignOut() {
        self.isUserCurrentlyLoggedOut.toggle()
        try? FirebaseManager.shared.auth.signOut()
       
    }
}

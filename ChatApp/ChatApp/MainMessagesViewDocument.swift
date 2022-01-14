//
//  MainMessagesViewDocument.swift
//  ChatApp
//
//  Created by Sahil Sahu on 25/11/21.
//

import Foundation
import Firebase
import FirebaseFirestore

class MainMessagesViewDocument: ObservableObject {
    
    @Published var chatUser: ChatUser?
    @Published var errorMessage: String = ""
    @Published var isUserCurrentlyLoggedOut:Bool
    @Published var recentMessages = [RecentMessage]()
    
    init() {
        self.isUserCurrentlyLoggedOut = FirebaseManager.shared.auth.currentUser?.uid == nil ? true : false
        fetchCurrentUser()
        fetchRecentMessages()
    }
    
    private var firestoreRegisteration: ListenerRegistration?
    
    func fetchRecentMessages() {
        guard let uid = FirebaseManager.shared.auth.currentUser?.uid else{return}
        
       
        firestoreRegisteration?.remove()
        recentMessages.removeAll()
        
        firestoreRegisteration = FirebaseManager.shared.firestore
            .collection("recent_messages")
            .document(uid)
            .collection("messages")
            .order(by: "timestamp")
            .addSnapshotListener { querySnapshot, error in
            
            if let error = error {
                print("failed to listen for recent messages" + error.localizedDescription)
                return
            }
            querySnapshot?.documentChanges.forEach({ change in
                
                    let docId = change.document.documentID
                    
                if let index = self.recentMessages.firstIndex(where: {rm in
                    rm.documentId == docId
                }){
                    self.recentMessages.remove(at: index)
                }
                self.recentMessages.insert(.init(documentId: docId, data: change.document.data()), at: 0)
            })
        }
        
    }
    
    func fetchCurrentUser() {
        
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
            
            FirebaseManager.shared.currentUser = self.chatUser
        }
        
    }
    
    func handleSignOut() {
        do{
            try FirebaseManager.shared.auth.signOut()

        }
        catch{
            self.errorMessage = error.localizedDescription
            print(error.localizedDescription)
        }
        
        self.chatUser = nil
        self.isUserCurrentlyLoggedOut.toggle()
    }
    
    
}

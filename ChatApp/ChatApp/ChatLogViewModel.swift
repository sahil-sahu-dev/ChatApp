//
//  ChatLogViewModel.swift
//  ChatApp
//
//  Created by Sahil Sahu on 03/12/21.
//

import Foundation
import Firebase

struct FirebaseConstants {
    
    static let fromId = "fromId"
    static let toId = "toId"
    static let text = "Text"
}

struct ChatMessage: Identifiable {
    
    var id: String { documentId }
    
    let documentId: String
    let fromId, toId, text: String
    
    init(documentId: String, data: [String: Any]) {
        self.documentId = documentId
        self.fromId = data[FirebaseConstants.fromId] as? String ?? ""
        self.toId = data[FirebaseConstants.toId] as? String ?? ""
        self.text = data[FirebaseConstants.text] as? String ?? ""
    }
    
}
class ChatLogViewModel: ObservableObject {
    
    @Published var chatText = ""
    @Published var errorMessage = ""
    @Published var chatMessages = [ChatMessage]()
    
    @Published var count = 0
    
    var chatUser: ChatUser?
    
    init(chatUser: ChatUser?) {
        self.chatUser = chatUser
        getMessages()
        
    }
    
    var firestoreListener: ListenerRegistration?
    
    func getMessages() {
        
        guard let fromId = FirebaseManager.shared.auth.currentUser?.uid else{return}
        guard let toId = chatUser?.uid else {return}
        
        chatMessages.removeAll()
        
        firestoreListener = FirebaseManager.shared.firestore.collection("messages")
            .document(fromId)
            .collection(toId)
            .order(by: "timestamp")
            .addSnapshotListener { querySnapshot, error in
                if let error = error {
                    print("Error getting messages from firestore \(error.localizedDescription)")
                    return
                }
                
                querySnapshot?.documentChanges.forEach({ change in
                    
                    let data = change.document.data()
                    self.chatMessages.append(ChatMessage(documentId: change.document.documentID, data: data))
                })
                
            }
        
        DispatchQueue.main.async {
            self.count += 1
        }
    }
    
    func handleSend() {
        guard let fromId = FirebaseManager.shared.auth.currentUser?.uid else{return}
        
        guard let toId = chatUser?.uid else {return}
        
        let document = FirebaseManager.shared.firestore.collection("messages")
            .document(fromId)
            .collection(toId)
            .document()
        
        let messageData = ["fromId": fromId, "toId": toId, "Text": chatText, "timestamp": Timestamp()] as [String: Any]
        
        document.setData(messageData) { error in
            
            if let err = error {
                print(err.localizedDescription)
                self.errorMessage = "failed to store message to firestore \(err.localizedDescription)"
                return
            }
            
            self.persistRecentMessage()
            
            //no errror
            print("stored the message to firebase")
            self.chatText = ""
        }
        
        let messageReceiverDocument = FirebaseManager.shared.firestore.collection("messages")
            .document(toId)
            .collection(fromId)
            .document()
        
        messageReceiverDocument.setData(messageData) { error in
            
            if let error = error {
                print(error)
                self.errorMessage = "failed to store message to firestore \(error)"
                return
            }
            
            //saved message successfully
            
            print("successfully stored receiver message")
            
        }
        
    }
    
    private func persistRecentMessage() {
        
        guard let uid = FirebaseManager.shared.auth.currentUser?.uid else {return}
        
        guard let toId = self.chatUser?.uid else{return}
        
        var doc = FirebaseManager.shared.firestore.collection("recent_messages").document(uid).collection("messages").document(toId)
        
        let data = [
            "timestamp" : Timestamp(),
            "Text": self.chatText,
            "fromId": uid,
            "toId" : toId,
            "profileImageUrl": self.chatUser?.imageProfile as Any,
            "email": self.chatUser?.email as Any
            
        ] as [String : Any]
        
        doc.setData(data) { error in
            if let error  = error {
                print("failed to store to recent messages" + error.localizedDescription)
                return
            }
        }
        
        print("saved to recent messages successfully")
        
        
        doc = FirebaseManager.shared.firestore.collection("recent_messages").document(toId).collection("messages").document(uid)
        
        guard let currentUser = FirebaseManager.shared.currentUser else { return }
        
        let recipientData =  [
            "timestamp" : Timestamp(),
            "Text": self.chatText,
            "fromId": uid,
            "toId" : toId,
            "profileImageUrl": currentUser.imageProfile as Any,
            "email": currentUser.email as Any
            
        ] as [String : Any]
        
        doc.setData(recipientData) { error in
            if let error  = error {
                print("failed to store to recent messages" + error.localizedDescription)
                return
            }
        }
        
        print("saved to recent messages successfully")
    }
    
}

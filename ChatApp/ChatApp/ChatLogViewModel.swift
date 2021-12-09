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
    let chatUser: ChatUser?
    
    init(chatUser: ChatUser?) {
        self.chatUser = chatUser
        getMessages()
        
    }
    
    func getMessages() {
        
        guard let fromId = FirebaseManager.shared.auth.currentUser?.uid else{return}
        guard let toId = chatUser?.uid else {return}
        
        FirebaseManager.shared.firestore.collection("messages")
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
    
}

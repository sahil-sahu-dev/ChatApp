//
//  ChatLogViewModel.swift
//  ChatApp
//
//  Created by Sahil Sahu on 03/12/21.
//

import Foundation
import Firebase

class ChatLogViewModel: ObservableObject {
    
    @Published var chatText = ""
    @Published var errorMessage = ""
    
    let chatUser: ChatUser?
    
    init(chatUser: ChatUser?) {
        self.chatUser = chatUser
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

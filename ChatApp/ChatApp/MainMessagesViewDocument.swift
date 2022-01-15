//
//  MainMessagesViewDocument.swift
//  ChatApp
//
//  Created by Sahil Sahu on 25/11/21.
//

import Foundation
import Firebase
import FirebaseFirestore
import CryptoKit
import KeychainAccess

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
            
            
            
            self.storePrivateKeyToKeychain() //fetch from keychain. if not present create and store to keychain
            self.updateUserInfo()
            FirebaseManager.shared.currentUser = self.chatUser
            
        }
        
    }
    
    func updateUserInfo() {
        
        guard let uid = FirebaseManager.shared.auth.currentUser?.uid else { return }
        
        let userData = ["email": self.chatUser?.email ?? "", "uid": uid, "profileImageUrl": self.chatUser?.imageProfile ?? "", "publicKey": self.chatUser?.publicKey ?? ""] as [String: Any]
        
        FirebaseManager.shared.firestore.collection("users")
            .document(uid).setData(userData) { err in
                if let err = err {
                    print(err)
                    return
                }
                
                print("Success")
                
            }
    }
    
    
    func removeFromKeychain() {
        
        let keychain = Keychain(service: "com.gmail@sahilsahudev")
        
        do {
            try keychain.remove("privateKey")
        } catch let error {
            print("error: \(error)")
        }
    }
    
    func storePrivateKeyToKeychain() {
        
        guard let uid = self.chatUser?.uid else {return}
        
        let keychain = Keychain(service: uid)
        let token = keychain["privateKey"]
        
        if let token = token {
            print("private key already present")
            //private key already exists
            let retrievedString = token
            do{
                print("String retrieved fro, private key = \(retrievedString)")
                self.chatUser?.privateKey = try Encryption.convertStringToPrivateKey(retrievedString)
            }
            catch{
                print("couldnt get back private key from the private key string")
            }
            
        }
        
        else{
            //there is no private key present
            print("No key present")
            let privateKey = Encryption.generatePrivateKey()
            let privateKeyString = Encryption.convertPrivateKeyToString(privateKey)
            
            do{
                try keychain.set(privateKeyString, key: "privateKey")
                self.chatUser?.privateKey = privateKey
            }
            catch{
                print("Couldnt store key to keychain " + error.localizedDescription)
            }
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




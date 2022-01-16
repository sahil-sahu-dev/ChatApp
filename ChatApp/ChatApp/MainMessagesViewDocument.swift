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
import UIKit

class MainMessagesViewDocument: ObservableObject {
    
    @Published var chatUser: ChatUser?
    
    @Published var errorMessage: String = ""
    @Published var isUserCurrentlyLoggedOut:Bool
    @Published var recentMessages = [RecentMessage]()
    @Published var userSignedInOnAnotherDevice = false
    
    
    init() {
        self.isUserCurrentlyLoggedOut = FirebaseManager.shared.auth.currentUser?.uid == nil ? true : false
        fetchCurrentUser{
            self.fetchRecentMessages()
        }
        
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
                    
                    var messageData = change.document.data()
                    
                    FirebaseManager.shared.firestore.collection("users").document(change.document.documentID).getDocument { snapshot, error in
                        
                        if let error = error {
                            print("Error getting public key -> fetch recent messages " + error.localizedDescription)
                            return
                        }
                        
                        //no error
                        guard let data = snapshot?.data() else{
                            return
                        }
                        
                        let publicKeyString = data["publicKey"] as? String
                        
                        do{
                            if let publicKey = try Encryption.convertStringToPublicKey(publicKeyString){
                                if let privateKey = self.chatUser?.privateKey{
                                    let symmetricKey = try Encryption.deriveSymmtericKey(privateKey: privateKey, publicKey: publicKey)
                                    messageData["Text"] = Decrpytion.decryptText(text:messageData["Text"] as? String ?? "",using:symmetricKey)
                                    
                                }
                                else{
                                    print("couldnt get private key")
                                }
                            }
                            else{
                                print("couldnt decrypt pb")
                            }
                            
                            
                        }
                        catch{
                            print(error.localizedDescription)
                        }
                        
                        
                        let docId = change.document.documentID
                        
                        if let index = self.recentMessages.firstIndex(where: {rm in
                            rm.documentId == docId
                        }){
                            self.recentMessages.remove(at: index)
                        }
                        self.recentMessages.insert(.init(documentId: docId, data: messageData), at: 0)
                        
                        
                    }
                    
                })
            }
        
    }
    
    func fetchCurrentUser(onCompletion: @escaping() -> ()) {
        
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
            
            if let isSignedIn = data["isSignedIn"] as? Bool, let deviceId = data["deviceId"] as? String? {
                if isSignedIn == true && deviceId != UIDevice.current.identifierForVendor?.uuidString {
                    //do not allow user to use app
                    self.userSignedInOnAnotherDevice = true
                    return
                }
            }
            
            self.storePrivateKeyToKeychain() //fetch from keychain. if not present create and store to keychain
            self.updateUserInfo()
            FirebaseManager.shared.currentUser = self.chatUser
            onCompletion()
        }
        
    }
    
    func updateUserInfo() {
        
        guard let uid = FirebaseManager.shared.auth.currentUser?.uid else { return }
        
        let userData = ["email": self.chatUser?.email ?? "", "uid": uid, "profileImageUrl": self.chatUser?.imageProfile ?? "", "publicKey": self.chatUser?.publicKey ?? "", "isSignedIn": true, "deviceId": UIDevice.current.identifierForVendor?.uuidString ?? ""] as [String: Any]
        
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
        
        guard let uid = FirebaseManager.shared.auth.currentUser?.uid else{return}
        FirebaseManager.shared.firestore.collection("users").document(uid).getDocument {snapshot, error in
            
            if let error = error {
                self.errorMessage = "Could not fetch user data \(error)"
                return
            }
            
            
            guard var data = snapshot?.data() else {
                self.errorMessage = "No data found"
                return
            }
            
            data["isSignedIn"] = false
            data["deviceId"] = ""
            FirebaseManager.shared.firestore.collection("users").document(uid).setData(data) { error in
                if let error = error {
                    print("Error setting data to firestore -> handle sign out")
                    print(error.localizedDescription)
                    return
                }
                
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
        
    }
}




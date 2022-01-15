//
//  ChatUser.swift
//  ChatApp
//
//  Created by Sahil Sahu on 25/11/21.
//

import Foundation
import CryptoKit

struct ChatUser:Identifiable {
    
    var id: String{uid}
    let uid: String
    let imageProfile: String
    let email: String
    var privateKey: P256.KeyAgreement.PrivateKey?
    var publicKey: String? {
        Encryption.exportPublicKey(privateKey?.publicKey) 
    }
}

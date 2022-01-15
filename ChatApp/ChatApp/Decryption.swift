//
//  Decryption.swift
//  ChatApp
//
//  Created by Sahil Sahu on 15/01/22.
//


import Foundation
import CryptoKit


class Decrpytion {
    
    static func decryptText(text: String, using symmetricKey: SymmetricKey) -> String {
        do {
            guard let data = Data(base64Encoded: text) else {
                return "Couldnt decode text"
        
            }
            
            let sealedBox = try AES.GCM.SealedBox(combined: data)
            let decyptedData = try AES.GCM.open(sealedBox, using: symmetricKey)
            
            guard let text = String(data: decyptedData, encoding: .utf8) else{
                return "Couldnt decode data"
            }
            
            return text
        }catch let error {
            return "Error decrpyting message \(error.localizedDescription)"
        }
    }
}

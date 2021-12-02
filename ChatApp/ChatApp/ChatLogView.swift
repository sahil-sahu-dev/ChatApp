//
//  ChatLogView.swift
//  ChatApp
//
//  Created by Sahil Sahu on 02/12/21.
//

import SwiftUI

struct ChatLogView: View {

    let chatUser: ChatUser?

    var body: some View {
        ScrollView {
            ForEach(0..<10) { num in
                Text("FAKE MESSAGE FOR NOW")
            }
        }.navigationTitle(chatUser?.email ?? "")
            .navigationBarTitleDisplayMode(.inline)
    }
}

//struct ChatLogView_Previews: PreviewProvider {
//    static var previews: some View {
//        ChatLogView()
//    }
//}

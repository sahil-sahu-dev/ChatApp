//
//  CreateNewMessageView.swift
//  ChatApp
//
//  Created by Sahil Sahu on 29/11/21.
//

import SwiftUI

struct CreateNewMessageView: View {
    
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject private var vm = CreateNewMessageViewModel()
    
    var body: some View {
        
        NavigationView{
            ScrollView {
                Text("\(vm.errorMessage)")
                ForEach(vm.users) { user in
                    Text("\(user.email)")
                }
            }
            
            .navigationTitle("New Message")
            .toolbar{
                ToolbarItem(placement: .navigationBarLeading){
                    Button {
                        presentationMode.wrappedValue.dismiss()
                    } label: {
                        Text("Cancel")
                            .foregroundColor(.blue)
                    }
                }
            }
        }
        
    }
}

struct CreateNewMessageView_Previews: PreviewProvider {
    static var previews: some View {
        CreateNewMessageView()
    }
}

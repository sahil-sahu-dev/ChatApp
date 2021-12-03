//
//  MainMessagesView.swift
//  ChatApp
//
//  Created by Sahil Sahu on 16/11/21.
//

import SwiftUI
import SDWebImageSwiftUI


struct MainMessagesView: View {
    
    @State var shouldShowLogOutOptions = false
    @State var shouldShowNewMessageView = false
    @State var shouldShowMessageLogView = false
    
    @ObservedObject var vm = MainMessagesViewDocument()
    
    
    private var customNavBar: some View {
        HStack(spacing: 16) {
            
            
            WebImage(url: URL(string: vm.chatUser?.imageProfile ?? ""))
                .resizable()
                .scaledToFill()
                .frame(width: 50, height: 50)
                .clipped()
                .cornerRadius(50)
                .overlay(RoundedRectangle(cornerRadius: 44)
                            .stroke(Color(.label), lineWidth: 1)
                )
                .shadow(radius: 5)
            
            
            
            VStack(alignment: .leading, spacing: 4) {
                Text("\(vm.chatUser?.email.replacingOccurrences(of: "@gmail.com", with: "") ?? "")")
                    .font(.system(size: 24, weight: .bold))
                
                HStack {
                    Circle()
                        .foregroundColor(.green)
                        .frame(width: 14, height: 14)
                    Text("online")
                        .font(.system(size: 12))
                        .foregroundColor(Color(.lightGray))
                }
                
            }
            
            Spacer()
            Button {
                shouldShowLogOutOptions.toggle()
            } label: {
                Image(systemName: "gear")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(Color(.label))
            }
        }
        .padding()
        .actionSheet(isPresented: $shouldShowLogOutOptions) {
            .init(title: Text("Settings"), message: Text("What do you want to do?"), buttons: [
                .destructive(Text("Sign Out"), action: {
                    
                    vm.handleSignOut()
                    
                    print("handle sign out")
                }),
                .cancel()
            ])
        }
        .fullScreenCover(isPresented: $vm.isUserCurrentlyLoggedOut, onDismiss: nil) {
            LoginView{
                self.vm.isUserCurrentlyLoggedOut = false
                vm.fetchCurrentUser()
            }
        }
    }
    
    @State var chatUser: ChatUser?
    
    var body: some View {
        
       
        NavigationView{
            VStack {
                Text(vm.errorMessage)
                customNavBar
                messagesView
                NavigationLink("", isActive:$shouldShowMessageLogView ) {
                    ChatLogView(chatUser: chatUser ?? nil)
                }
            }
            .overlay(
                newMessageButton, alignment: .bottom)
            .navigationBarHidden(true)
        }
    }
    
    
    private var messagesView: some View {
        ScrollView {
            ForEach(0..<10, id: \.self) { num in
                
                Button {
                    
                } label: {
                    VStack {
                        HStack(spacing: 16) {
                            Image(systemName: "person.fill")
                                .font(.system(size: 32))
                                .padding(8)
                                .overlay(RoundedRectangle(cornerRadius: 44)
                                            .stroke(Color(.label), lineWidth: 1)
                                )
                            
                            
                            VStack(alignment: .leading) {
                                Text("Username")
                                    .font(.system(size: 16, weight: .bold))
                                Text("Message sent to user")
                                    .font(.system(size: 14))
                                    .foregroundColor(Color(.lightGray))
                            }
                            Spacer()
                            
                            Text("22d")
                                .font(.system(size: 14, weight: .semibold))
                        }
                        Divider()
                            .padding(.vertical, 8)
                    }.padding(.horizontal)
                        .foregroundColor(Color(.label))
                }
                
            }.padding(.bottom, 50)
        }
    }
    
    
    private var newMessageButton: some View {
        Button {
            self.shouldShowNewMessageView.toggle()
        } label: {
            HStack {
                Spacer()
                Text("+ New Message")
                    .font(.system(size: 16, weight: .bold))
                Spacer()
            }
            .foregroundColor(.white)
            .padding(.vertical)
            .background(Color.blue)
            .cornerRadius(32)
            .padding(.horizontal)
            .shadow(radius: 15)
        }
        
        .fullScreenCover(isPresented: $shouldShowNewMessageView) {
            CreateNewMessageView { user in
                self.chatUser = user
                shouldShowMessageLogView.toggle()
            }
        }
    }
    
    
    
}

struct MainMessagesView_Previews: PreviewProvider {
    static var previews: some View {
        MainMessagesView()
    }
}

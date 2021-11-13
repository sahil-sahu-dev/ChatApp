//
//  ContentView.swift
//  ChatApp
//
//  Created by Sahil Sahu on 13/11/21.
//

import SwiftUI

struct LoginView: View {
    
    @State private var isLoginMode = false
    @State private var email = ""
    @State private var password = ""
    
    var body: some View {
        NavigationView{
            ScrollView{
               
                    VStack{
                        segmentedPicker
                        
                        if !isLoginMode {
                            personButtonView
                        }
                        
                        emailTextField
                        passwordTextField
                        createAccountButton
                        
                    }
                .padding()
            }
            .navigationTitle(isLoginMode ? "Log in": "Create Account")
            .background(Color(.init(white: 0, alpha: 0.05)).ignoresSafeArea())
        }
        
    }
    
    private var emailTextField: some View {
        TextField("Email", text: $email)
            .keyboardType(.emailAddress)
            .autocapitalization(.none)
            .padding()
            .background(Color.white)
    }
    
    private var passwordTextField: some View {
        SecureField("Password", text: $password)
            .padding()
            .background(Color.white)
    }
    
    private var segmentedPicker: some View {
        Picker(selection: $isLoginMode, label: Text("Picker here")) {
            Text("Create Account").tag(false)
            Text("Login").tag(true)
        }
        .pickerStyle(SegmentedPickerStyle())
        .padding()
    }
    
    private var personButtonView: some View {
        Button {
            
        } label: {
            Image(systemName: "person.fill")
                .font(.largeTitle)
        }.padding()
    }
    
    private var createAccountButton: some View {
        Button {
            
        }label: {
            HStack {
                Spacer()
                Text(isLoginMode ? "Log In" : "Create Account")
                    .foregroundColor(.white)
                    .fontWeight(.bold)
                    .padding()
                    .font(.subheadline)
                Spacer()
            }
            .background(Color.blue).cornerRadius(20)
            .padding()
        }
    }
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}

//
//  ContentView.swift
//  ChatApp
//
//  Created by Sahil Sahu on 13/11/21.
//

import SwiftUI
import Firebase


struct LoginView: View {
    
    @State private var isLoginMode = false
    @State private var email = ""
    @State private var password = ""
    
    
    var body: some View {
        NavigationView{
            ScrollView{
               
                VStack(spacing: 20){
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
        .navigationViewStyle(StackNavigationViewStyle())
        
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
            handleAction()
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
    
    private func handleAction() {
        if isLoginMode {
            //login
            login()
            
        }
        else{
            //create new account
            createNewAccount()
        }
    }
    
    private func createNewAccount() {
        FirebaseManager.shared.auth.createUser(withEmail: email, password: password) { result, error in
            
            if let error = error {
                print("Couldnt create new user \n\n" + error.localizedDescription)
            }
            
        }
    }
    
    private func login() {
        FirebaseManager.shared.auth.signIn(withEmail: email, password: password) { result, error in
            if let error = error {
                print("Error logging in" + error.localizedDescription)
            }
            else{
                print("Successfully logged in as user: \(result?.user.uid ?? "")")
            }
            
        }
    }
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}

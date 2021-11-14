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
    @State private var loginStatusMessage = ""
    @State private var shouldShowImagePicker = false
    @State private var image: UIImage?
    
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
                        Text(loginStatusMessage)
                        
                    }
                .padding()
            }
            .navigationTitle(isLoginMode ? "Log in": "Create Account")
            .background(Color(.init(white: 0, alpha: 0.05)).ignoresSafeArea())
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .fullScreenCover(isPresented: $shouldShowImagePicker, onDismiss: nil) {
            ImagePicker(image: $image)
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
            shouldShowImagePicker.toggle()
            
        } label: {
            VStack {
                if let image = image {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 128, height: 128)
                        .cornerRadius(64)
                }
                else{
                    Image(systemName: "person.fill")
                        .font(.system(size: 64))
                        .padding()
                        .foregroundColor(Color(.label))
                        
                }
            }
            .overlay(RoundedRectangle(cornerRadius: 64).stroke(Color.black, lineWidth: 3))
            
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
            storeImage()
        }
    }
    
    private func createNewAccount() {
        FirebaseManager.shared.auth.createUser(withEmail: email, password: password) { result, error in
            
            if let error = error {
                print("Couldnt create new user \n\n" + error.localizedDescription)
            }
            
            print("Successfully created user: \(result?.user.uid ?? "")")
            self.loginStatusMessage = "Successfully created user: \(result?.user.uid ?? "")"
            
        }
    }
    
    private func login() {
        FirebaseManager.shared.auth.signIn(withEmail: email, password: password) { result, error in
            if let error = error {
                print("Error logging in" + error.localizedDescription)
            }
            else{
                
                print("Successfully logged in as user: \(result?.user.uid ?? "")")
                loginStatusMessage = "Successfully logged in as user: \(result?.user.uid ?? "")"

            }
            
        }
    }
    
    
    private func storeImage() {
        guard let uid = FirebaseManager.shared.auth.currentUser?.uid else {return}
        let ref = FirebaseManager.shared.storage.reference(withPath: uid)
        guard let imageData = image?.jpegData(compressionQuality: 0.5) else{return}
        
        ref.putData(imageData, metadata: nil) { metadata, err in
            if let error = err {
                loginStatusMessage = "Failed to push image to storage \(error)"
                return
            }
            
            ref.downloadURL { url, err in
                if let error = err {
                    loginStatusMessage = "Failed to download image url \(error)"
                }
                
                loginStatusMessage = "Successfully store image to firebase with url \(String(describing: url?.absoluteString))"
            }
            
        }
    }
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}

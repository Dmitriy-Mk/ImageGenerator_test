//
// SignInScreen.swift
// ImageEditor_TestTask
//
// Created by Dmitriy Mk on 15.05.25.
//


import SwiftUI


struct SignInScreen: View {
    
    @State private var email: String = ""
    @State private var password: String = ""
    
    var body: some View {
        ZStack(alignment: .center) {
            VStack(spacing: 12) {
                
                Text("Sign In")
                
                TextField("Insert email", text: $email)
                
                SecureField("Insert password", text: $password)
                
                Button("Sign In with Google") {
                    print("Google")
                }
                
                Text("or")
                
                Button("Reset password") {
                    print("Google")
                }
            }
        }
    }
}

#Preview {
    SignInScreen()
}

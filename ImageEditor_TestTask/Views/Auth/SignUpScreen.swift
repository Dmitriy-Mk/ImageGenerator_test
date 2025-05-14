//
// SignUpScreen.swift
// ImageEditor_TestTask
//
// Created by Dmitriy Mk on 14.05.25.
//


import SwiftUI

struct SignUpScreen: View {
    
    @State private var email: String = ""
    @State private var password: String = ""
    
    var body: some View {
        VStack {
            Text("Create your profile")
                .font(.largeTitle)
                .bold()
            
            TextField("Insert Email", text: $email)
                .textInputAutocapitalization(.never)
                .padding()
                .textFieldStyle(.roundedBorder)
            
            SecureField("Insert Password", text: $password)
                .textInputAutocapitalization(.never)
                .padding()
                .textFieldStyle(.roundedBorder)
            
            SecureField("Confirm Password", text: $password)
                .textInputAutocapitalization(.never)
                .padding()
                .textFieldStyle(.roundedBorder)
            
            Button("Sign up") {
               
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }
}

#Preview {
    SignUpScreen()
}

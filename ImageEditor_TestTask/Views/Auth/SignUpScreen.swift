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
    @State private var confirmPassword: String = ""
    
    private var isSignUpButtonDisabled: Bool {
        email.isEmpty || password.isEmpty || confirmPassword.isEmpty || password != confirmPassword
    }
    private enum Constants {
        static let textFieldVerticalPadding: CGFloat = 20.0
    }
    
    var body: some View {
        VStack(spacing: 12) {
            Text("Create your profile")
                .font(.largeTitle)
                .bold()
                .padding(.bottom, 24)
            
            TextField("Insert Email", text: $email)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .textFieldStyle(.roundedBorder)
                .padding([.leading, .trailing], Constants.textFieldVerticalPadding)
            
            SecureField("Insert Password", text: $password)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .textFieldStyle(.roundedBorder)
                .padding([.leading, .trailing], Constants.textFieldVerticalPadding)
            
            SecureField("Confirm Password", text: $confirmPassword)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .textFieldStyle(.roundedBorder)
                .padding([.leading, .trailing], Constants.textFieldVerticalPadding)
            
            Button("Sign up") {
                print("Proceed to sign up")
            }
            .buttonStyle(.borderedProminent)
            .padding(.top, 16)
            .disabled(isSignUpButtonDisabled)
            .opacity(isSignUpButtonDisabled ? 0.5 : 1.0)
        }
        .padding(.horizontal)
    }
}

#Preview {
    SignUpScreen()
}

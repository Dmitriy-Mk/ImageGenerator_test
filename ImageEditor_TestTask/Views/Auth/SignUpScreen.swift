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
    
    
    private enum Constants {
        static let textFieldHorizontalPadding: CGFloat = 20.0
    }
    private var isSignUpButtonDisabled: Bool {
        email.isEmpty || password.isEmpty || confirmPassword.isEmpty || password != confirmPassword
    }
    private var isValidEmail: Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        return email.range(of: emailRegex, options: .regularExpression, range: nil, locale: nil) != nil
    }
    private var showEmailValidation: Bool {
        !email.isEmpty
    }
    private var showPasswordValidation: Bool {
        !(password.isEmpty || confirmPassword.isEmpty)
    }
    private var showPasswordMatching: Bool {
        password == confirmPassword
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
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(
                            showEmailValidation ? (isValidEmail ? Color.green : Color.red) : Color.clear,
                            lineWidth: 1
                        )
                )
                .textFieldStyle(.roundedBorder)
                .padding([.leading, .trailing], Constants.textFieldHorizontalPadding)
            
            SecureField("Insert Password", text: $password)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(
                            showPasswordValidation ? (showPasswordMatching ? Color.green : Color.red) : Color.clear,
                            lineWidth: 1
                        )
                )
                .textFieldStyle(.roundedBorder)
                .padding([.leading, .trailing], Constants.textFieldHorizontalPadding)
            
            SecureField("Confirm Password", text: $confirmPassword)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(
                            showPasswordValidation ? (showPasswordMatching ? Color.green : Color.red) : Color.clear,
                            lineWidth: 1
                        )
                )
                .textFieldStyle(.roundedBorder)
                .padding([.leading, .trailing], Constants.textFieldHorizontalPadding)
            
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

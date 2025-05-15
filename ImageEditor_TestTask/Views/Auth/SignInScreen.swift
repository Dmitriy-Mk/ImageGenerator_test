//
// SignInScreen.swift
// ImageEditor_TestTask
//
// Created by Dmitriy Mk on 15.05.25.
//


import SwiftUI

struct SignInScreen<ViewModel>: View
where ViewModel: ViewModelType
{
    
    //MARK: - States
    @State private var email: String = ""
    @State private var password: String = ""
    @FocusState private var focusedField: Field?
    
    //MARK: - Properties
    private var isValidEmail: Bool {
        let regex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        return email.range(of: regex, options: .regularExpression, range: nil, locale: nil) != nil
    }
    private var showEmailValidation: Bool {
        !email.isEmpty
    }
    private var isSignInButtonDisabled: Bool {
        email.isEmpty || password.isEmpty || isValidEmail == false
    }
    @ObservedObject private var viewModel: ViewModel
    
    // MARK: - Initialization
    init(viewModel: ViewModel) {
        self.viewModel = viewModel
    }
    
    //MARK: - Body
    var body: some View {
        ZStack(alignment: .center) {
            VStack(spacing: 12) {
                
                PrimaryTitle(text: "Sign In")
                
                PrimaryTextField(
                    title: "Insert Email",
                    bindedText: $email,
                    showEmailValidation: showEmailValidation,
                    isValidEmail: isValidEmail
                )
                .padding([.leading, .trailing], MainConstants.textFieldHorizontalPadding.rawValue)
                .focused($focusedField, equals: .email)
                
                PrimarySecureField(title: "Insert password", bindedText: $password)
                .padding([.leading, .trailing], MainConstants.textFieldHorizontalPadding.rawValue)
                .focused($focusedField, equals: .email)
                
                PrimaryButton(
                    title: "Sign in",
                    action: {
                        // viewModel.signIn(email: email, password: password)
                        viewModel.isLoading = true
                    },
                    isDisabled: isSignInButtonDisabled
                )
                
                SecondaryButton(
                    title: "Sign In with Google",
                    action: {
                        // viewModel.signInGoogle(email: email, password: password)
                        viewModel.isLoading = true
                    }
                )
                
                Text("or")
                    .padding(.top, MainConstants.primaryVerticalPadding.rawValue)
                
                Button("Reset password") {
                    print("Google")
                }
                .padding(.top, MainConstants.primaryVerticalPadding.rawValue)
            }
            .padding(.horizontal)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(.systemGroupedBackground))
            .ignoresSafeArea()
            .hideKeyboardOnTap($focusedField)
            .alert("Error",
                   isPresented: .constant(viewModel.errorMessage != nil),
                   actions: {
                Button("OK", role: .cancel) {
                    viewModel.errorMessage = nil
                }
            }, message: {
                Text(viewModel.errorMessage ?? "")
            })
            
            if viewModel.isLoading {
                Color.black.opacity(0.4)
                    .ignoresSafeArea()
                
                VStack {
                    ProgressView("Loading…")
                        .padding()
                        .background(Color.white)
                        .cornerRadius(10)
                        .shadow(radius: 10)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .ignoresSafeArea()
            }
        }
    }
}

#Preview {
    SignInScreen(viewModel: AuthViewModel(authService: AuthService()))
}

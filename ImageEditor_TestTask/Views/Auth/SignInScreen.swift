//
// SignInScreen.swift
// ImageEditor_TestTask
//
// Created by Dmitriy Mk on 15.05.25.
//


import SwiftUI

struct SignInScreen<ViewModel>: View
where ViewModel: AuthViewModelType
{
    
    //MARK: - States
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var goToSignUp = false
    @State private var showResetPasswordScreen: Bool = false
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
        NavigationStack {
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
                    .font(Font.system(size: 15))
                    
                    Button("Reset password") {
                        showResetPasswordScreen = true
                    }
                    .font(Font.system(size: 15))
                    .tint(Color.red)
                    .padding(.top, MainConstants.primaryVerticalPadding.rawValue)
                    .sheet(isPresented: $showResetPasswordScreen) {
                        print(showResetPasswordScreen)
                    } content: {
                        ResetPasswordScreen(viewModel: AuthViewModel(authService: AuthService()))
                    }
                    
                    Text("or")
                        .padding(.top, MainConstants.primaryVerticalPadding.rawValue)
                    
                    SecondaryButton(title: "Register Account") {
                        goToSignUp = true
                    }
                }
                .modifier(PrimaryVerticalStackStyle())
                .hideKeyboardOnTap($focusedField)
                .navigationDestination(isPresented: $goToSignUp, destination: {
                    SignUpScreen(viewModel: viewModel)
                })
                .alert("Error",
                       isPresented: .constant(viewModel.errorMessage != nil),
                       actions: {
                    Button("OK", role: .cancel) {
                        viewModel.errorMessage = nil
                    }
                }, message: {
                    Text(viewModel.errorMessage ?? "")
                })
                .alert("Signed in",
                       isPresented: Binding(
                        get: { viewModel.showSuccessMessage == true },
                        set: { _ in viewModel.showSuccessMessage = nil }
                       ), actions: {
                           Button("OK") {
                               viewModel.showSuccessMessage = nil
                           }
                       }, message: {
                           Text("You have successfully signed in!")
                       })
                
                // MARK: Loading Indicator
                .withLoadingOverlay(isLoading: viewModel.isLoading)
            }
        }
    }
}

#Preview {
    SignInScreen(viewModel: AuthViewModel(authService: AuthService()))
}

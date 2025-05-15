//
// SignUpScreen.swift
// ImageEditor_TestTask
//
// Created by Dmitriy Mk on 14.05.25.
//


import SwiftUI

struct SignUpScreen<ViewModel>: View
where ViewModel: ViewModelType
{

    // MARK: - States
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var confirmPassword: String = ""
    @FocusState private var focusedField: Field?

    // MARK: - Properties
    private var isSignUpButtonDisabled: Bool {
        email.isEmpty || password.isEmpty || confirmPassword.isEmpty ||
        password != confirmPassword ||
        isValidEmail == false
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
    @ObservedObject private var viewModel: ViewModel

    // MARK: - Initialization
    init(viewModel: ViewModel) {
        self.viewModel = viewModel
    }

    // MARK: - Body
    var body: some View {
        ZStack(alignment: .center) {
            VStack(spacing: 12) {
                
                PrimaryTitle(text: "Create your profile")
                
                PrimaryTextField(
                    title: "Insert Email",
                    bindedText: $email,
                    showEmailValidation: showEmailValidation,
                    isValidEmail: isValidEmail
                )
                .padding([.leading, .trailing], MainConstants.textFieldHorizontalPadding.rawValue)
                .focused($focusedField, equals: .email)
                
                PrimarySecureField(
                    title: "Insert Password",
                    bindedText: $password,
                    showPasswordValidation: showPasswordValidation,
                    showPasswordMatching: showPasswordMatching
                )
                .padding([.leading, .trailing], MainConstants.textFieldHorizontalPadding.rawValue)
                .focused($focusedField, equals: .password)
                
                PrimarySecureField(
                    title: "Confirm Password",
                    bindedText: $confirmPassword,
                    showPasswordValidation: showPasswordValidation,
                    showPasswordMatching: showPasswordMatching
                )
                .padding([.leading, .trailing], MainConstants.textFieldHorizontalPadding.rawValue)
                .focused($focusedField, equals: .password)
                
                PrimaryButton(
                    title: "Sign up",
                    action: {
                        // viewModel.signUp(email: email, password: password)
                        viewModel.isLoading = true
                    },
                    isDisabled: isSignUpButtonDisabled
                )
            }
            .modifier(PrimaryVerticalStackStyle())
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
            .alert("The letter has been sent",
                   isPresented: Binding(
                    get: { viewModel.showSuccessMessage == true },
                    set: { _ in viewModel.showSuccessMessage = nil }
                   ), actions: {
                       Button("OK") {
                           viewModel.showSuccessMessage = nil
                       }
                   }, message: {
                       Text("Please follow the link in your mail to activate your account.")
                   })

            // MARK: Loading Indicator
            .withLoadingOverlay(isLoading: viewModel.isLoading)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Preview Provider
#Preview {
    SignUpScreen(viewModel: AuthViewModel(authService: AuthService()))
}

//
// SignUpScreen.swift
// ImageEditor_TestTask
//
// Created by Dmitriy Mk on 14.05.25.
//

import SwiftUI

struct SignUpScreen<ViewModel>: View
where ViewModel: AuthViewModelType {

    // MARK: - States
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var confirmPassword: String = ""
    @State private var showSuccessAlert: Bool = false
    @State private var showErrorMessage: Bool = false
    @FocusState private var focusedField: Field?
    @Environment(\.dismiss) private var dismiss

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

        GeometryReader(content: { geometry in

            ZStack(alignment: .center) {
                VStack(spacing: 12) {

                    PrimaryTitle(text: "Create your profile")

                    PrimaryTextField(
                        title: "Insert Email",
                        bindedText: $email,
                        showEmailValidation: showEmailValidation,
                        isValidEmail: isValidEmail
                    )
                    .padding([.leading, .trailing])
                    .frame(width: geometry.size.width / 2, height: AuthConstants.textFieldHeight)
                    .focused($focusedField, equals: .email)

                    PrimarySecureField(
                        title: "Insert Password",
                        bindedText: $password,
                        showPasswordValidation: showPasswordValidation,
                        showPasswordMatching: showPasswordMatching
                    )
                    .padding([.leading, .trailing])
                    .frame(width: geometry.size.width / 2, height: AuthConstants.textFieldHeight)
                    .focused($focusedField, equals: .password)

                    PrimarySecureField(
                        title: "Confirm Password",
                        bindedText: $confirmPassword,
                        showPasswordValidation: showPasswordValidation,
                        showPasswordMatching: showPasswordMatching
                    )
                    .padding([.leading, .trailing])
                    .frame(width: geometry.size.width / 2, height: AuthConstants.textFieldHeight)
                    .focused($focusedField, equals: .password)

                    PrimaryButton(
                        title: "Sign up",
                        action: {
                            viewModel.signUp(email: email, password: password)
                        },
                        isDisabled: isSignUpButtonDisabled
                    )
                }
                .modifier(PrimaryVerticalStackStyle())
                .hideKeyboardOnTap($focusedField)
                .onChange(of: viewModel.showSignUpSuccessMessage, { _, newValue in
                    if newValue == true {
                        showSuccessAlert = true
                    }
                })
                .onChange(of: showSuccessAlert, { _, newValue in
                    if newValue == true {
                        viewModel.showSignUpSuccessMessage = nil
                    }
                })
                .onChange(of: viewModel.errorMessage != nil, { _, newValue in
                    if newValue == true {
                        viewModel.errorMessage = nil
                        showErrorMessage = true
                    }
                })
                .alert("Signed up",
                       isPresented: $showSuccessAlert,
                       actions: {
                    Button("OK") {
                        showSuccessAlert = false
                        dismiss()
                    }
                }, message: {
                    Text("Please confirm your email address, from link on your mailbox!")
                })
                .alert("Error",
                       isPresented: $showErrorMessage,
                       actions: {
                    Button("OK", role: .cancel) {
                        showErrorMessage = false
                    }
                }, message: {
                    Text(viewModel.errorMessage ?? "")
                })

                // MARK: Loading Indicator
                .withLoadingOverlay(isLoading: viewModel.isLoading)
            }
        }
        )
    }
}

// MARK: - Preview Provider
#Preview {
    SignUpScreen(
        viewModel: AuthViewModel(
            authService: AuthService(),
            googleSignInService: GoogleSignInService()
        )
    )
}

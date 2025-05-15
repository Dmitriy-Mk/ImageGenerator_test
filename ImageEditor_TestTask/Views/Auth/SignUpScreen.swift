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
                    .padding([.leading, .trailing], MainConstants.textFieldHorizontalPadding.rawValue)
                    .focused($focusedField, equals: .email)
                
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
                    .padding([.leading, .trailing], MainConstants.textFieldHorizontalPadding.rawValue)
                    .focused($focusedField, equals: .password)
                
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
                    .padding([.leading, .trailing], MainConstants.textFieldHorizontalPadding.rawValue)
                    .focused($focusedField, equals: .confirmPassword)
                
                Button("Sign up") {
                    // viewModel.signUp(email: email, password: password)
                    viewModel.isLoading = true
                }
                .buttonStyle(.borderedProminent)
                .padding(.top, 16)
                .disabled(isSignUpButtonDisabled)
                .opacity(isSignUpButtonDisabled ? 0.5 : 1.0)
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
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Preview Provider
#Preview {
    SignUpScreen(viewModel: AuthViewModel(authService: AuthService()))
}

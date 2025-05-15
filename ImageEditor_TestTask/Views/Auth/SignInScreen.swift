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
    private enum Constants: CGFloat {
        case textFieldHorizontalPadding = 20.0
        case secondaryHorizontalPadding = 0.0
    }
    private var isValidEmail: Bool {
        let regex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        return email.range(of: regex, options: .regularExpression, range: nil, locale: nil) != nil
    }
    private var isSignUpButtonDisabled: Bool {
        email.isEmpty || password.isEmpty || isValidEmail == false
    }
    private var showEmailValidation: Bool {
        !email.isEmpty
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
                
                Text("Sign In")
                    .font(.largeTitle)
                    .bold()
                    .padding(.bottom, 24)
                
                TextField("Insert email", text: $email)
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
                    .padding([.leading, .trailing], Constants.textFieldHorizontalPadding.rawValue)
                    .focused($focusedField, equals: .email)
                
                SecureField("Insert password", text: $password)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .textFieldStyle(.roundedBorder)
                    .padding([.leading, .trailing], Constants.textFieldHorizontalPadding.rawValue)
                    .focused($focusedField, equals: .email)
                
                Button("Sign in") {
                    // viewModel.signIn(email: email, password: password)
                    viewModel.isLoading = true
                }
                .buttonStyle(.borderedProminent)
                .padding(.top, Constants.secondaryHorizontalPadding.rawValue)
                .disabled(isSignUpButtonDisabled)
                .opacity(isSignUpButtonDisabled ? 0.5 : 1.0)
                
                Button("Sign In with Google") {
                    print("Google")
                }
                .buttonStyle(.bordered)
                .padding(.top, Constants.secondaryHorizontalPadding.rawValue)
                
                Text("or")
                    .padding(.top, Constants.secondaryHorizontalPadding.rawValue)
                
                Button("Reset password") {
                    print("Google")
                }
                .padding(.top, Constants.secondaryHorizontalPadding.rawValue)
            }
            .frame(width: .infinity, height: .infinity, alignment: .center)
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

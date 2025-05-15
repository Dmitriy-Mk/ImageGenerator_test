//
// ResetPasswordScreen.swift
// ImageEditor_TestTask
//
// Created by Dmitriy Mk on 15.05.25.
//


import SwiftUI

struct ResetPasswordScreen<ViewModel>: View
where ViewModel: AuthViewModelType
{

    //MARK: - States
    @State private var email: String = ""
    @FocusState private var focusedField: Field?
    @Environment(\.dismiss) private var dismiss
    
    //MARK: - Properties
    private var isValidEmail: Bool {
        let regex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        return email.range(of: regex, options: .regularExpression, range: nil, locale: nil) != nil
    }
    private var showEmailValidation: Bool {
        !email.isEmpty
    }
    private var resetButtonDisabled: Bool {
        email.isEmpty || isValidEmail == false
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
                
                PrimaryTitle(text: "Reset Password")
                
                PrimaryTextField(
                    title: "Insert Email",
                    bindedText: $email,
                    showEmailValidation: showEmailValidation,
                    isValidEmail: isValidEmail
                )
                .textFieldStyle(.roundedBorder)
                .padding([.leading, .trailing], MainConstants.textFieldHorizontalPadding.rawValue)
                .focused($focusedField, equals: .email)
                
                PrimaryButton(
                    title: "Reset",
                    action: {
                        // viewModel.resetPassword(email: email, password: password)
                        viewModel.isLoading = true
                        
                        //MARK: Immitation
                        Task {
                            try? await Task.sleep(nanoseconds: 3 * 1_000_000_000)
                            viewModel.isLoading = false
                            viewModel.showSuccessMessage = true
                        }
                    },
                    isDisabled: resetButtonDisabled
                )
                .padding(.top, MainConstants.secondaryVerticalPadding.rawValue)
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
            .alert("Password reset",
                   isPresented: Binding(
                    get: { viewModel.showSuccessMessage == true },
                    set: { _ in viewModel.showSuccessMessage = nil }
                   ), actions: {
                       Button("OK") {
                           viewModel.showSuccessMessage = nil
                           dismiss()
                       }
                   }, message: {
                       Text("Check your email to reset your password.")
                   })
            
            // MARK: Loading Indicator
            .withLoadingOverlay(isLoading: viewModel.isLoading)
        }
    }
}

#Preview {
    ResetPasswordScreen(viewModel: AuthViewModel(authService: AuthService()))
}

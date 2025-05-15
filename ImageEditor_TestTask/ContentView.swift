//
// ContentView.swift
// ImageEditor_TestTask
//
// Created by Dmitriy Mk on 13.05.25.
//


import SwiftUI

struct ContentView<ViewModel>: View
where ViewModel: AuthViewModelType
{
    
    @StateObject private var authViewModel: ViewModel
    
    init(authViewModel: ViewModel) {
        _authViewModel = StateObject(wrappedValue: authViewModel)
    }
    
    var body: some View {
        Group {
            switch authViewModel.appState {
            case .editor:
                ImageEditorScreen(viewModel: authViewModel)
            case .onboarding:
                AuthFlowView(authViewModel: authViewModel)
            }
        }
    }
}

#Preview {
    ContentView(authViewModel: AuthViewModel(authService: AuthService()))
}

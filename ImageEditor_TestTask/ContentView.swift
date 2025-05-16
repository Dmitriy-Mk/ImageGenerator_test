//
// ContentView.swift
// ImageEditor_TestTask
//
// Created by Dmitriy Mk on 13.05.25.
//

import SwiftUI

struct ContentView<AuthViewModel, EditorViewModel>: View
where AuthViewModel: AuthViewModelType, EditorViewModel: ImageEditorViewModelInterfaceType {

    @StateObject private var authViewModel: AuthViewModel
    @StateObject private var editorViewModel: EditorViewModel

    init(authViewModel: AuthViewModel, editorViewModel: EditorViewModel) {
        _authViewModel = StateObject(wrappedValue: authViewModel)
        _editorViewModel = StateObject(wrappedValue: editorViewModel)
    }

    var body: some View {
        Group {
            switch authViewModel.appState {
            case .editor:
#warning("Add Coordinator")
                ImageEditorScreen(
                    viewModel: editorViewModel,
                    authViewModel: authViewModel
                )
            case .onboarding:
                AuthFlowView(authViewModel: authViewModel)
            }
        }
    }
}

#Preview {
    ContentView<AuthViewModel, ImageEditorViewModel>(
        authViewModel: AuthViewModel(
            authService: AuthService(),
            googleSignInService: GoogleSignInService()
        ),
        editorViewModel: ImageEditorViewModel(photoLibService: PhotoLibraryService())
    )
}

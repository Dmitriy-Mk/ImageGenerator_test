//
// FlowView.swift
// ImageEditor_TestTask
//
// Created by Dmitriy Mk on 15.05.25.
//

import SwiftUI

struct AuthFlowView<ViewModel>: View
where ViewModel: AuthViewModelType {

    @ObservedObject private var authViewModel: ViewModel

    init(authViewModel: ViewModel) {
        self.authViewModel = authViewModel
    }

    var body: some View {
        NavigationStack {
            SignInScreen(viewModel: authViewModel)
        }
    }
}

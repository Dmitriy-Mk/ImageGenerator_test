//
// ImageEditorScreen.swift
// ImageEditor_TestTask
//
// Created by Dmitriy Mk on 15.05.25.
//


import SwiftUI

struct ImageEditorScreen<ViewModel>: View
where ViewModel: AuthViewModelType
{
    
    @ObservedObject private var viewModel: ViewModel
    
    init(viewModel: ViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        
        VStack {
            PrimaryButton(title: "Sign Out") {
                viewModel.signOut()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.red)
    }
}

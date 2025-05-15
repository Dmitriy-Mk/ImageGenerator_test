//
// PrimaryButtonStyle.swift
// ImageEditor_TestTask
//
// Created by Dmitriy Mk on 15.05.25.
//


import SwiftUI

struct PrimaryButtonStyle: ViewModifier {
    var isDisabled: Bool
    var padding: EdgeInsets

    func body(content: Content) -> some View {
        content
            .frame(maxWidth: .infinity)
            .padding(padding)
            .background(isDisabled ? Color.gray : Color.blue)
            .foregroundColor(.white)
            .cornerRadius(8)
            .disabled(isDisabled)
            .opacity(isDisabled ? 0.6 : 1.0)
    }
}

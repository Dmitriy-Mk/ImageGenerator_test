//
// PrimaryButtonStyle.swift
// ImageEditor_TestTask
//
// Created by Dmitriy Mk on 15.05.25.
//


import SwiftUI

struct PrimaryButtonStyle: ViewModifier {
    
    var isDisabled: Bool

    func body(content: Content) -> some View {
        content
            .disabled(isDisabled)
    }
}

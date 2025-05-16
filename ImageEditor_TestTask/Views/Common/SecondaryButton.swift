//
// SecondaryButton.swift
// ImageEditor_TestTask
//
// Created by Dmitriy Mk on 15.05.25.
//

import SwiftUI

struct SecondaryButton: View {

    let title: String
    let action: () -> Void
    var isDisabled: Bool = false

    var body: some View {
        Button(title, action: action)
            .buttonStyle(.bordered)
            .modifier(PrimaryButtonStyle(isDisabled: isDisabled))
    }
}

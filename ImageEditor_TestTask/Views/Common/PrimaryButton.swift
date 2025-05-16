//
// PrimaryButton.swift
// ImageEditor_TestTask
//
// Created by Dmitriy Mk on 15.05.25.
//

import SwiftUI

struct PrimaryButton: View {

    let title: String
    let action: () -> Void
    var isDisabled: Bool = false

    var body: some View {
        Button(title, action: action)
            .buttonStyle(.borderedProminent)
            .modifier(PrimaryButtonStyle(isDisabled: isDisabled))
    }
}

#Preview {
    PrimaryButton(
        title: "Test",
        action: { },
        isDisabled: false
    )
}

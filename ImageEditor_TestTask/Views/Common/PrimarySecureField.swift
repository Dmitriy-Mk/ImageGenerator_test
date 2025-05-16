//
// PrimarySecureField.swift
// ImageEditor_TestTask
//
// Created by Dmitriy Mk on 15.05.25.
//

import SwiftUI

struct PrimarySecureField: View {

    let title: String
    let bindedText: Binding<String>
    let showPasswordValidation: Bool
    let showPasswordMatching: Bool

    init(
        title: String,
        bindedText: Binding<String>,
        showPasswordValidation: Bool = false,
        showPasswordMatching: Bool = false
    ) {
        self.title = title
        self.bindedText = bindedText
        self.showPasswordValidation = showPasswordValidation
        self.showPasswordMatching = showPasswordMatching
    }

    var body: some View {
        SecureField(title, text: bindedText)
            .textInputAutocapitalization(.never)
            .autocorrectionDisabled()
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(
                        showPasswordValidation ? (showPasswordMatching ? Color.green : Color.red) : Color.clear,
                        lineWidth: 1
                    )
            )
            .textFieldStyle(.roundedBorder)
    }
}

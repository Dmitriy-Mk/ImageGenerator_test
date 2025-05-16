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
            .padding(.horizontal, 12)
            .frame(height: AuthConstants.textFieldHeight)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(
                        showPasswordValidation ? (
                            showPasswordMatching ? Color.green : Color.red
                        ) : Color.gray.opacity(0.6),
                        lineWidth: 1
                    )
                    .background(.white)
            )
            .font(.system(size: ImageEditorConstants.textFieldFontSize))
    }
}

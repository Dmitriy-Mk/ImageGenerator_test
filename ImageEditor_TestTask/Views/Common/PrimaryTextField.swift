//
// PrimaryTextField.swift
// ImageEditor_TestTask
//
// Created by Dmitriy Mk on 15.05.25.
//

import SwiftUI

struct PrimaryTextField: View {

    let title: String
    let bindedText: Binding<String>
    let showEmailValidation: Bool
    let isValidEmail: Bool

    init(
        title: String,
        bindedText: Binding<String>,
        showEmailValidation: Bool = false,
        isValidEmail: Bool = false
    ) {
        self.title = title
        self.bindedText = bindedText
        self.showEmailValidation = showEmailValidation
        self.isValidEmail = isValidEmail
    }

    var body: some View {
        TextField(title, text: bindedText)
            .padding(.horizontal, 12)
            .frame(height: AuthConstants.textFieldHeight)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(
                        showEmailValidation ? (isValidEmail ? Color.green : Color.red) : Color.gray.opacity(0.6),
                        lineWidth: 1
                    )
                    .background(.white)
            )
            .font(.system(size: ImageEditorConstants.textFieldFontSize))
    }
}

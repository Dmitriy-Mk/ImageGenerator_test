//
// TapGesture+ResignResonder.swift
// ImageEditor_TestTask
//
// Created by Dmitriy Mk on 15.05.25.
//

import SwiftUI

extension View {
    func hideKeyboardOnTap(_ focusedField: FocusState<Field?>.Binding) -> some View {
        self.onTapGesture {
            focusedField.wrappedValue = nil
            UIApplication.shared.sendAction(
                #selector(UIResponder.resignFirstResponder),
                to: nil,
                from: nil,
                for: nil
            )
        }
    }
}

//
// PrimaryProgressViewStyle.swift
// ImageEditor_TestTask
//
// Created by Dmitriy Mk on 15.05.25.
//

import SwiftUI

struct PrimaryProgressViewStyle: ViewModifier {

    let cornerRadius: CGFloat
    let shadowRadius: CGFloat

    init(cornerRadius: CGFloat = 10,
         shadowRadius: CGFloat = 10) {
        self.cornerRadius = cornerRadius
        self.shadowRadius = shadowRadius
    }

    func body(content: Content) -> some View {
        content
            .padding()
            .background(Color.white)
            .cornerRadius(cornerRadius)
            .shadow(radius: shadowRadius)
    }
}

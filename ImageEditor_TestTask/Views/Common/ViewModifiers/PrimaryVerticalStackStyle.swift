//
// PrimaryStackStyle.swift
// ImageEditor_TestTask
//
// Created by Dmitriy Mk on 15.05.25.
//


import SwiftUI

struct PrimaryVerticalStackStyle: ViewModifier {
    
    func body(content: Content) -> some View {
        content
        .padding(.horizontal)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemGroupedBackground))
        .ignoresSafeArea()
    }
}

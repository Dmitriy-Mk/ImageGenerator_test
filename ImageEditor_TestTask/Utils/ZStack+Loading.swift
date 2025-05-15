//
// ZStack+Loading.swift
// ImageEditor_TestTask
//
// Created by Dmitriy Mk on 15.05.25.
//


import SwiftUI

import SwiftUI

struct LoadingOverlayModifier: ViewModifier {
    let isLoading: Bool
    let title: String

    func body(content: Content) -> some View {
        ZStack {
            content

            if isLoading {
                Color.black.opacity(0.4)
                    .ignoresSafeArea()

                VStack {
                    PrimaryProgressView(title: title)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
    }
}

extension View {
    func withLoadingOverlay(isLoading: Bool, title: String = "Loading...") -> some View {
        self.modifier(LoadingOverlayModifier(isLoading: isLoading, title: title))
    }
}


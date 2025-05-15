//
// MovableText.swift
// ImageEditor_TestTask
//
// Created by Dmitriy Mk on 16.05.25.
//


import SwiftUI

struct MovableText: View {
    @Binding var overlay: TextOverlay
    @GestureState private var dragOffset: CGSize = .zero
    
    var body: some View {
        Text(overlay.text)
            .font(overlay.font)
            .foregroundColor(overlay.color)
            .font(.system(size: overlay.size))
            .offset(x: overlay.offset.width + dragOffset.width,
                    y: overlay.offset.height + dragOffset.height)
            .gesture(
                DragGesture()
                    .updating($dragOffset) { value, state, _ in
                        state = value.translation
                    }
                    .onEnded { value in
                        overlay.offset.width  += value.translation.width
                        overlay.offset.height += value.translation.height
                    }
            )
    }
}

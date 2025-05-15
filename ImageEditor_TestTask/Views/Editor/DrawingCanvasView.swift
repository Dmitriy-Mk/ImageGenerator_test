//
// DrawingCanvasView.swift
// ImageEditor_TestTask
//
// Created by Dmitriy Mk on 16.05.25.
//


import SwiftUI
import PencilKit

struct DrawingCanvasView: UIViewRepresentable {
    @Binding var canvasView: PKCanvasView
    @Binding var isDrawingEnabled: Bool

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    func makeUIView(context: Context) -> PKCanvasView {
        let canvas = canvasView
        canvas.backgroundColor = .clear
        canvas.drawingPolicy = .anyInput

        if let windowScene = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene }).first
        {
            let toolPicker = PKToolPicker()
            context.coordinator.toolPicker = toolPicker

            toolPicker.setVisible(isDrawingEnabled, forFirstResponder: canvas)
            toolPicker.addObserver(canvas)
            canvas.becomeFirstResponder()
        }
        return canvas
    }

    func updateUIView(_ uiView: PKCanvasView, context: Context) {
        guard let toolPicker = context.coordinator.toolPicker else { return }
        if isDrawingEnabled {
            toolPicker.setVisible(true, forFirstResponder: uiView)
            uiView.becomeFirstResponder()
        } else {
            toolPicker.setVisible(false, forFirstResponder: uiView)
            uiView.resignFirstResponder()
        }
    }

    class Coordinator: NSObject {
        var toolPicker: PKToolPicker?
    }
}

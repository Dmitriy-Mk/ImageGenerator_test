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

        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            let toolPicker = PKToolPicker()
            toolPicker.setVisible(isDrawingEnabled, forFirstResponder: canvas)
            toolPicker.addObserver(canvas)
            context.coordinator.toolPicker = toolPicker
        }

        return canvas
    }

    func updateUIView(_ uiView: PKCanvasView, context: Context) {
        guard let toolPicker = context.coordinator.toolPicker else { return }

        DispatchQueue.main.async {
            if isDrawingEnabled {
                toolPicker.setVisible(true, forFirstResponder: uiView)
                uiView.becomeFirstResponder()
            } else {
                toolPicker.setVisible(false, forFirstResponder: uiView)
                uiView.resignFirstResponder()
            }
        }
    }

    class Coordinator: NSObject {
        var toolPicker: PKToolPicker?
    }
}

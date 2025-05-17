//
// DrawingCanvasView.swift
// ImageEditor_TestTask
//
// Created by Dmitriy Mk on 16.05.25.
//

import SwiftUI
import PencilKit

/// A SwiftUI wrapper for `PKCanvasView` enabling PencilKit drawing functionality.
///
/// This view displays a canvas for drawing, optionally overlaying a selected background image.
/// It integrates the `PKToolPicker` to provide drawing tools when drawing mode is enabled.
///
/// - Note: This struct manages the visibility and responder status of the `PKToolPicker`
///   based on the `isDrawingEnabled` binding.
///
/// Usage:
/// ```swift
/// @State private var canvasView = PKCanvasView()
/// @State private var isDrawingEnabled = false
/// @State private var selectedImage: UIImage? = nil
///
/// DrawingCanvasView(
///     canvasView: $canvasView,
///     isDrawingEnabled: $isDrawingEnabled,
///     selectedImage: selectedImage
/// )
/// ```
struct DrawingCanvasView: UIViewRepresentable {
    /// The PencilKit canvas view bound from SwiftUI.
    @Binding var canvasView: PKCanvasView
    /// Controls whether drawing mode is enabled and the tool picker is visible.
    @Binding var isDrawingEnabled: Bool
    /// Optional image to display as the background of the canvas.
    var selectedImage: UIImage?

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    func makeUIView(context: Context) -> UIView {
        let container = CanvasContainerView(canvasView: canvasView)
        container.updateImage(selectedImage)

        if UIApplication.shared.connectedScenes.first is UIWindowScene {
            let toolPicker = PKToolPicker()
            toolPicker.setVisible(isDrawingEnabled, forFirstResponder: canvasView)
            toolPicker.addObserver(canvasView)
            context.coordinator.toolPicker = toolPicker
        }

        return container
    }

    func updateUIView(_ uiView: UIView, context: Context) {
        guard let container = uiView as? CanvasContainerView,
              let toolPicker = context.coordinator.toolPicker else { return }

        container.updateImage(selectedImage)

        DispatchQueue.main.async {
            if isDrawingEnabled {
                toolPicker.setVisible(true, forFirstResponder: canvasView)
                canvasView.becomeFirstResponder()
            } else {
                toolPicker.setVisible(false, forFirstResponder: canvasView)
                canvasView.resignFirstResponder()
            }
        }

        container.updateCanvasView(canvasView)
    }

    /// Coordinator to manage `PKToolPicker` lifecycle and interactions.
    class Coordinator: NSObject {
        var toolPicker: PKToolPicker?
    }
}

/// A container UIView that hosts a UIImageView and a PKCanvasView layered together,
/// along with a hidden SwiftUI SizeReaderView to measure its size.
///
/// The container handles layout and updates of the background image and canvas.
final class CanvasContainerView: UIView {
    private var hostingController: UIHostingController<SizeReaderView>?
    private let imageView = UIImageView()
    private let canvasView: PKCanvasView

    /// Initializes the container with the given `PKCanvasView`.
    /// - Parameter canvasView: The PencilKit canvas view to embed.
    init(canvasView: PKCanvasView) {
        self.canvasView = canvasView
        super.init(frame: .zero)

        addSubview(imageView)
        backgroundColor = .clear
        canvasView.backgroundColor = .clear

        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            imageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: trailingAnchor),
            imageView.topAnchor.constraint(equalTo: topAnchor),
            imageView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])

        addSubview(canvasView)
        canvasView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            canvasView.leadingAnchor.constraint(equalTo: leadingAnchor),
            canvasView.trailingAnchor.constraint(equalTo: trailingAnchor),
            canvasView.topAnchor.constraint(equalTo: topAnchor),
            canvasView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])

        let reader = SizeReaderView()
        let host = UIHostingController(rootView: reader)
        host.view.backgroundColor = .clear
        addSubview(host.view)
        sendSubviewToBack(host.view)
        host.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            host.view.leadingAnchor.constraint(equalTo: leadingAnchor),
            host.view.trailingAnchor.constraint(equalTo: trailingAnchor),
            host.view.topAnchor.constraint(equalTo: topAnchor),
            host.view.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        hostingController = host
    }

    /// Updates the background image displayed behind the canvas.
    /// - Parameter image: The new image to display.
    func updateImage(_ image: UIImage?) {
        imageView.image = image
    }

    /// Placeholder for updating the canvas view, currently no-op.
    /// - Parameter newCanvasView: The updated `PKCanvasView`.
    func updateCanvasView(_ newCanvasView: PKCanvasView) { }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

/// A SwiftUI view that reads the size of its container using a GeometryReader
/// and publishes it via a preference key.
struct SizeReaderView: View {
    var body: some View {
        GeometryReader { geometry in
            Color.clear
                .preference(key: CanvasSizeKey.self, value: geometry.size)
        }
    }
}

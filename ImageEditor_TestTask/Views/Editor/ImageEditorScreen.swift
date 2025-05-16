//
// ImageEditorScreen.swift
// ImageEditor_TestTask
//
// Created by Dmitriy Mk on 15.05.25.
//

import SwiftUI
import PhotosUI
import AVFoundation
import PencilKit

struct ImageEditorScreen<ViewModel>: View
where ViewModel: ImageEditorViewModelInterfaceType
{
    @StateObject private var viewModel: ViewModel
    
    // MARK: — Text
    @State private var newText: String = ""
    @State private var selectedFont: Font = .title
    @State private var selectedColor: Color = .white
    @State private var selectedSize: CGFloat = 24
    
    // MARK: — Gestures
    @State private var scale: CGFloat = 1.0
    @GestureState private var gestureScale: CGFloat = 1.0
    @State private var rotation: Angle = .zero
    @GestureState private var gestureRotation: Angle = .zero
    
    // MARK: — Photo
    @State private var showPhotoPicker = false
    @State private var showCamera = false
    @State private var imageSource: UIImagePickerController.SourceType = .photoLibrary
    
    // MARK: — PencilKit
    @State private var canvasView = PKCanvasView()
    @State private var isDrawingEnabled = false
    
    //MARK: - Photo Export
    @State private var showSaveAlert = false
    @State private var showShare = false
    @State private var shareImage: UIImage? = nil

    init(viewModel: ViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        VStack {
            
            if isDrawingEnabled {
                Button("Done Drawing") {
                    isDrawingEnabled = false
                }
                .padding()
            }
            
            ZStack {
                
                if let image = viewModel.filteredImage {
                    imageView(image)
                } else if let image = viewModel.selectedImage {
                    imageView(image)
                } else {
                    Text("No image selected")
                        .foregroundColor(.gray)
                }
                
                //MARK: Drawing Layer
                if viewModel.selectedImage != nil {
                    DrawingCanvasView(
                        canvasView: $canvasView,
                        isDrawingEnabled: $isDrawingEnabled
                    )
                    .allowsHitTesting(isDrawingEnabled)
                }
                
                //MARK: Applying Text Overlays
                ForEach($viewModel.textOverlays) { $overlay in
                    MovableText(overlay: $overlay)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            textTools
            toolButtons
            
            //MARK: Save Photo
            Button("Save to Photos") {
                let targetSize = UIScreen.main.bounds.size
                viewModel.saveToPhotoLibrary(
                    canvasView: canvasView,
                    targetSize: targetSize
                ) { result in
                    switch result {
                    case .success: showSaveAlert = true
                    case .failure: break
                    }
                }
            }
            
            //MARK: Share
            Button("Share") {
                shareImage = viewModel.renderFinalImage(
                    canvasView: canvasView,
                    in: UIScreen.main.bounds.size
                )
            }
            .sheet(item: $shareImage) { img in
                ShareSheet(items: [img])
            }
        }
        .alert("Saved!", isPresented: $showSaveAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("Your image was saved to Photos.")
        }
        .sheet(isPresented: $showPhotoPicker) {
            ImagePicker(sourceType: imageSource) { image in
                viewModel.selectedImage = image
                viewModel.resetImageFilter()
            }
        }
        .padding()
    }
    
    // MARK: — MagnificationGesture and RotationGesture for Picked Image
    @ViewBuilder
    private func imageView(_ uiImage: UIImage) -> some View {
        GeometryReader { geo in
            Image(uiImage: uiImage)
                .resizable()
                .scaledToFit()
                .frame(width: geo.size.width, height: geo.size.height)
                .scaleEffect(scale * gestureScale)
                .rotationEffect(rotation + gestureRotation)
                .gesture(
                    SimultaneousGesture(
                        MagnificationGesture()
                            .updating($gestureScale) { v, s, _ in s = v }
                            .onEnded { scale *= $0 },
                        RotationGesture()
                            .updating($gestureRotation) { a, s, _ in s = a }
                            .onEnded { rotation += $0 }
                    )
                )
        }
    }
    
    // MARK: - Instruments
    private var textTools: some View {
        VStack(alignment: .center, spacing: 8) {
            HStack {
                TextField("Enter text", text: $newText)
                    .textFieldStyle(.roundedBorder)
                    .frame(maxWidth: 170)
                
                Button("Add Text") {
                    let uiFont: UIFont
                    switch selectedFont {
                    case .title:
                        uiFont = UIFont.preferredFont(forTextStyle: .title1)
                    case .body:
                        uiFont = UIFont.preferredFont(forTextStyle: .body)
                    default:
                        uiFont = UIFont.systemFont(ofSize: selectedSize)
                    }
                    
                    let overlay = TextOverlay(
                        text: newText,
                        font: uiFont,
                        color: selectedColor,
                        size: selectedSize
                    )
                    viewModel.textOverlays.append(overlay)
                    newText = ""
                }
                .disabled(newText.isEmpty)
            }
            HStack {
                Menu("Font") {
                    Button("Title") { selectedFont = .title }
                    Button("Body")  { selectedFont = .body }
                }
                
                ColorPicker("Color", selection: $selectedColor)
                    .padding(.leading, 10)
                
                Slider(value: $selectedSize, in: 12...72) {
                    Text("Size")
                }
                .frame(width: 100)
            }
            .frame(width: 240)
        }
    }
    
    // MARK: — Tool Buttons
    private var toolButtons: some View {
        HStack(alignment: .center, spacing: 14) {
            Button("Draw") {
                isDrawingEnabled.toggle()
            }
            
            Button("Library") {
                imageSource = .photoLibrary
                showPhotoPicker = true
            }
            
            Button("Camera") {
                checkCameraPermission { granted in
                    if granted {
                        imageSource = .camera
                        showPhotoPicker = true
                    }
                }
            }
            
            //MARK: Menu for Filters
            Menu("Filters") {
                Button("Sepia") {
                    viewModel.applySepiaFilter(intensity: 1.0)
                }
                Button("Mono") {
                    viewModel.applyFilter(name: "CIPhotoEffectMono")
                }
                Button("Noir") {
                    viewModel.applyFilter(name: "CIPhotoEffectNoir")
                }
                Button("Chrome") {
                    viewModel.applyFilter(name: "CIPhotoEffectChrome")
                }
                Button("Fade") {
                    viewModel.applyFilter(name: "CIPhotoEffectFade")
                }
                Button("Reset") {
                    viewModel.resetImageFilter()
                }
            }
            .menuStyle(BorderlessButtonMenuStyle())
        }
        .padding()
        .frame(height: 30)
    }
    
    private func checkCameraPermission(completion: @escaping (Bool) -> Void) {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            completion(true)
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                DispatchQueue.main.async { completion(granted) }
            }
        default:
            completion(false)
        }
    }
}

extension UIImage: @retroactive Identifiable {
    public var id: String { self.pngData()?.base64EncodedString() ?? UUID().uuidString }
}

#Preview {
    ImageEditorScreen(viewModel: ImageEditorViewModel())
}


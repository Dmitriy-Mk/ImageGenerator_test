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
    
    // MARK: - Drawing & Gestures
    private let canvasView = PKCanvasView() // KEEP single instance to persist drawing
    @State private var isDrawingEnabled = false
    
    @State private var scale: CGFloat = 1.0
    @GestureState private var gestureScale: CGFloat = 1.0
    @State private var rotation: Angle = .zero
    @GestureState private var gestureRotation: Angle = .zero
    
    // MARK: - Text Overlay
    @State private var newText: String = ""
    @State private var selectedFont: Font = .title
    @State private var selectedColor: Color = .white
    @State private var selectedSize: CGFloat = 24
    
    // MARK: - Photo & Sharing
    @State private var selectedItem: PhotosPickerItem?
    @State private var showCamera = false
    @State private var showSaveAlert = false
    @State private var shareImage: UIImage?
    
    init(viewModel: ViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                ZStack {
                    if let image = viewModel.filteredImage ?? viewModel.selectedImage {
                        imageView(image)
                    } else {
                        Text("No image selected")
                            .foregroundColor(.gray)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .background(Color(UIColor.systemBackground))
                    }
                    
                    if viewModel.selectedImage != nil {
                        DrawingCanvasView(canvasView: .constant(canvasView), isDrawingEnabled: $isDrawingEnabled)
                            .allowsHitTesting(isDrawingEnabled)
                    }
                    
                    ForEach($viewModel.textOverlays) { $overlay in
                        MovableText(overlay: $overlay)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color(UIColor.systemBackground))
                .overlay(alignment: .topTrailing) {
                    if isDrawingEnabled {
                        Button("Done", role: .cancel) {
                            isDrawingEnabled = false
                        }
                        .buttonStyle(.borderedProminent)
                        .padding()
                    }
                }
                
                Divider()
                
                VStack(spacing: 10) {
                    TextTools(
                        newText: newText,
                        selectedFont: selectedFont,
                        selectedSize: selectedSize,
                        selectedColor: selectedColor,
                        viewModel: viewModel
                    )
                    .padding(.horizontal)
                    .opacity(viewModel.selectedImage != nil ? 1 : 0)
                    
                    HStack(spacing: 16) {
                        Button {
                            isDrawingEnabled.toggle()
                        } label: {
                            Label("Draw", systemImage: "pencil.tip.crop.circle")
                        }
                        
                        PhotosPicker(selection: $selectedItem, matching: .images) {
                            Label("Library", systemImage: "photo.on.rectangle")
                        }
                        .onChange(of: selectedItem) { newItem in
                            Task {
                                if let data = try? await newItem?.loadTransferable(type: Data.self),
                                   let image = UIImage(data: data) {
                                    viewModel.selectedImage = image
                                    viewModel.resetImageFilter()
                                }
                            }
                        }
                        
                        Button {
                            checkCameraPermission { granted in
                                if granted {
                                    showCamera = true
                                }
                            }
                        } label: {
                            Label("Camera", systemImage: "camera")
                        }
                        
                        Menu {
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
                        } label: {
                            Label("Filters", systemImage: "camera.filters")
                        }
                        
                        Button {
                            let targetSize = UIScreen.main.bounds.size
                            viewModel.saveToPhotoLibrary(canvasView: canvasView, targetSize: targetSize) { result in
                                if case .success = result {
                                    showSaveAlert = true
                                }
                            }
                        } label: {
                            Label("Save", systemImage: "square.and.arrow.down")
                        }
                        
                        Button {
                            shareImage = viewModel.renderFinalImage(canvasView: canvasView, in: UIScreen.main.bounds.size)
                        } label: {
                            Label("Share", systemImage: "square.and.arrow.up")
                        }
                    }
                    .labelStyle(IconOnlyLabelStyle())
                    .frame(height: 44)
                    .padding(.horizontal)
                }
                .padding(.bottom)
                .background(.ultraThinMaterial)
            }
            .navigationTitle("Editor")
            .navigationBarTitleDisplayMode(.inline)
        }
        .sheet(isPresented: $showCamera) {
            ImagePicker(sourceType: .camera) { image in
                viewModel.selectedImage = image
                viewModel.resetImageFilter()
            }
        }
        .sheet(item: $shareImage) { image in
            ShareSheet(items: [image])
        }
        .alert("Saved!", isPresented: $showSaveAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("Your image was saved to Photos.")
        }
    }
    
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
                            .updating($gestureScale) { value, state, _ in state = value }
                            .onEnded { scale *= $0 },
                        RotationGesture()
                            .updating($gestureRotation) { angle, state, _ in state = angle }
                            .onEnded { rotation += $0 }
                    )
                )
        }
    }
}

#Preview {
    ImageEditorScreen(viewModel: ImageEditorViewModel())
}


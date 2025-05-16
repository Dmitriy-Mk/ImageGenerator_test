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

struct ImageEditorScreen<EditorViewModel, AuthViewModel>: View
where EditorViewModel: ImageEditorViewModelInterfaceType, AuthViewModel: AuthViewModelType {

    @StateObject private var editorViewModel: EditorViewModel
    @StateObject private var authViewModel: AuthViewModel

    // MARK: - Drawing & Gestures
    private let canvasView = PKCanvasView()
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

    init(viewModel: EditorViewModel, authViewModel: AuthViewModel) {
        _editorViewModel = StateObject(wrappedValue: viewModel)
        _authViewModel = StateObject(wrappedValue: authViewModel)
    }

    var body: some View {

        NavigationView {

            ZStack(alignment: .topLeading) {

                VStack(spacing: 0) {
                    ZStack {
                        if let image = editorViewModel.filteredImage ?? editorViewModel.selectedImage {
                            imageView(image)
                        } else {
                            Text("No image selected")
                                .foregroundColor(.gray)
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                .background(Color(UIColor.systemBackground))
                        }

                        if editorViewModel.selectedImage != nil {
                            DrawingCanvasView(canvasView: .constant(canvasView), isDrawingEnabled: $isDrawingEnabled)
                                .allowsHitTesting(isDrawingEnabled)
                        }

                        ForEach($editorViewModel.textOverlays) { $overlay in
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
                            viewModel: editorViewModel
                        )
                        .padding(.horizontal)
                        .opacity(editorViewModel.selectedImage != nil ? 1 : 0)

                        HStack(spacing: 16) {
                            Button {
                                isDrawingEnabled.toggle()
                            } label: {
                                Label("Draw", systemImage: "pencil.tip.crop.circle")
                            }

                            PhotosPicker(selection: $selectedItem, matching: .images) {
                                Label("Library", systemImage: "photo.on.rectangle")
                            }
                            .onChange(of: selectedItem, { _, newValue in
                                Task {
                                    if let data = try? await newValue?.loadTransferable(type: Data.self),
                                       let image = UIImage(data: data) {
                                        editorViewModel.selectedImage = image
                                        editorViewModel.resetImageFilter()
                                    }
                                }
                            })

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
                                    editorViewModel.applySepiaFilter(intensity: 1.0)
                                }
                                Button("Mono") {
                                    editorViewModel.applyFilter(name: "CIPhotoEffectMono")
                                }
                                Button("Noir") {
                                    editorViewModel.applyFilter(name: "CIPhotoEffectNoir")
                                }
                                Button("Chrome") {
                                    editorViewModel.applyFilter(name: "CIPhotoEffectChrome")
                                }
                                Button("Fade") {
                                    editorViewModel.applyFilter(name: "CIPhotoEffectFade")
                                }
                                Button("Reset") {
                                    editorViewModel.resetImageFilter()
                                }
                            } label: {
                                Label("Filters", systemImage: "camera.filters")
                            }

                            Button {
                                let targetSize = UIScreen.main.bounds.size
                                editorViewModel.saveToPhotoLibrary(
                                    canvasView: canvasView,
                                    targetSize: targetSize
                                ) { result in
                                    if case .success = result {
                                        showSaveAlert = true
                                    }
                                }
                            } label: {
                                Label("Save", systemImage: "square.and.arrow.down")
                            }

                            Button {
                                shareImage = editorViewModel.renderFinalImage(
                                    canvasView: canvasView,
                                    in: UIScreen.main.bounds.size
                                )
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
            }
            .navigationTitle("Editor")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Sign Out") {
                        authViewModel.signOut()
                    }
                    .buttonStyle(.bordered)
                }
            }
        }
        .sheet(isPresented: $showCamera) {
            ImagePicker(sourceType: .camera) { image in
                editorViewModel.selectedImage = image
                editorViewModel.resetImageFilter()
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
    ImageEditorScreen(
        viewModel: ImageEditorViewModel(photoLibService: PhotoLibraryService()),
        authViewModel: AuthViewModel(
            authService: AuthService(),
            googleSignInService: GoogleSignInService()
        )
    )
}

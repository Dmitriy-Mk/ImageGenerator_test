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
    
    //MARK: - Text
    @State private var newText: String = ""
    @State private var selectedFont: Font = .title
    @State private var selectedColor: Color = .white
    @State private var selectedSize: CGFloat = 24
    
    //MARK: - Gestures
    @State private var scale: CGFloat = 1.0
    @GestureState private var gestureScale: CGFloat = 1.0
    @State private var rotation: Angle = .zero
    @GestureState private var gestureRotation: Angle = .zero
    
    //MARK: - Photo
    @State private var showPhotoPicker = false
    @State private var showCamera = false
    @State private var imageSource: UIImagePickerController.SourceType = .photoLibrary
    
    //MARK: - PencilKit
    @State private var canvasView = PKCanvasView()
    @State private var isDrawingEnabled = false
    
    init(viewModel: ViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        VStack {
            ZStack {
                
                // MARK: Magnification and Rotation Gestures for Picked Image
                if let image = viewModel.selectedImage {
                    GeometryReader { geo in
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .frame(width: geo.size.width, height: geo.size.height)
                            .scaleEffect(scale * gestureScale)
                            .rotationEffect(rotation + gestureRotation)
                            .gesture(
                                SimultaneousGesture(
                                    MagnificationGesture()
                                        .updating($gestureScale) { value, state, _ in state = value }
                                        .onEnded { value in scale *= value },
                                    RotationGesture()
                                        .updating($gestureRotation) { angle, state, _ in state = angle }
                                        .onEnded { angle in rotation += angle }
                                )
                            )
                    }
                } else {
                    Text("No image selected")
                        .foregroundColor(.gray)
                }
                
                // MARK: Drawing layer
                if viewModel.selectedImage != nil {
                    DrawingCanvasView(
                        canvasView: $canvasView,
                        isDrawingEnabled: $isDrawingEnabled
                    )
                    .allowsHitTesting(isDrawingEnabled)
                }
                
                
                // MARK: Text Overlays
                ForEach($viewModel.textOverlays) { $overlay in
                    MovableText(overlay: $overlay)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            //MARK: - Text UI
            HStack(alignment: .center) {
                TextField("Enter text", text: $newText)
                    .textFieldStyle(.roundedBorder)
                    .frame(maxWidth: 170)
                
                Button("Add Text") {
                    let overlay = TextOverlay(
                        text: newText,
                        font: selectedFont,
                        color: selectedColor,
                        size: selectedSize
                    )
                    viewModel.textOverlays.append(overlay)
                    newText = ""
                }
                .disabled(newText.isEmpty)
            }
            .frame(width: 300)

            //MARK: - Text Options Configuration
            HStack(alignment: .center) {
                Menu("Font") {
                    Button("Title") { selectedFont = .title }
                    Button("Body")  { selectedFont = .body }
                }
                
                ColorPicker("Color", selection: $selectedColor)
                    .padding(.leading, 10)
                
                Slider(value: $selectedSize, in: 12...72, label: {
                    Text("Size")
                })
                .frame(width: 100)
            }
            .frame(width: 240)
            
            //MARK: - Instruments
            HStack(alignment: .center) {
                Button(isDrawingEnabled ? "Done Drawing" : "Draw") {
                    isDrawingEnabled.toggle()
                }
                .padding()
                
                Button("Library") {
                    imageSource = .photoLibrary
                    showPhotoPicker = true
                }
                .padding()
                
                Button("Camera") {
                    checkCameraPermission { granted in
                        if granted {
                            imageSource = .camera
                            showCamera = true
                        }
                    }
                }
                .padding()
            }
            .padding(.zero)
            .frame(width: 300, height: 25)
        }
        .sheet(isPresented: $showPhotoPicker) {
            ImagePicker(sourceType: imageSource) { image in
                viewModel.selectedImage = image
            }
        }
        .padding()
    }
    
    func checkCameraPermission(completion: @escaping (Bool) -> Void) {
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

#Preview {
    ImageEditorScreen(viewModel: ImageEditorViewModel())
}

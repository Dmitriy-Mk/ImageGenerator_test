//
// ImageEditorScreen.swift
// ImageEditor_TestTask
//
// Created by Dmitriy Mk on 15.05.25.
//


import SwiftUI
import PhotosUI
import AVFoundation

struct ImageEditorScreen<ViewModel>: View
where ViewModel: ImageEditorViewModelInterfaceType
{
    @StateObject private var viewModel: ViewModel
    
    @State private var scale: CGFloat = 1.0
    @GestureState private var gestureScale: CGFloat = 1.0
    
    @State private var rotation: Angle = .zero
    @GestureState private var gestureRotation: Angle = .zero
    
    @State private var showPhotoPicker = false
    @State private var showCamera = false
    @State private var imageSource: UIImagePickerController.SourceType = .photoLibrary
    
    init(viewModel: ViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        VStack {
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
                                    .updating($gestureScale) { value, state, _ in
                                        state = value
                                    }
                                    .onEnded { value in
                                        scale *= value
                                    },
                                RotationGesture()
                                    .updating($gestureRotation) { angle, state, _ in
                                        state = angle
                                    }
                                    .onEnded { angle in
                                        rotation += angle
                                    }
                            )
                        )
                }
            } else {
                Text("No image selected")
                    .foregroundColor(.gray)
            }
            
            HStack {
                Button("Library") {
                    imageSource = .photoLibrary
                    showPhotoPicker = true
                }
                Button("Camera") {
                    checkCameraPermission { granted in
                        if granted {
                            imageSource = .camera
                            showCamera = true
                        }
                    }
                }
            }
            .padding()
        }
        .sheet(isPresented: $showPhotoPicker) {
            ImagePicker(sourceType: imageSource) { image in
                viewModel.selectedImage = image
            }
        }
    }
    
    func checkCameraPermission(completion: @escaping (Bool) -> Void) {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            completion(true)
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                DispatchQueue.main.async {
                    completion(granted)
                }
            }
        case .denied, .restricted:
            completion(false)
        @unknown default:
            completion(false)
        }
    }
}

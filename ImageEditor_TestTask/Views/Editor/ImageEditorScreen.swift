//
// ImageEditorScreen.swift
// ImageEditor_TestTask
//
// Created by Dmitriy Mk on 15.05.25.
//


import SwiftUI
import PhotosUI

struct ImageEditorScreen<ViewModel>: View
where ViewModel: ImageEditorViewModelInterfaceType
{
    
    @StateObject private var viewModel: ViewModel
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
                        .clipped()
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
                    imageSource = .camera
                    showCamera = true
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
}


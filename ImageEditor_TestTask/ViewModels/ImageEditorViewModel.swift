//
// ImageEditorViewModel.swift
// ImageEditor_TestTask
//
// Created by Dmitriy Mk on 16.05.25.
//


import SwiftUI
import PhotosUI

typealias ImageEditorViewModelInterfaceType = ObservableObject & ImageEditorViewModelInterface

protocol ImageEditorViewModelInterface {
    var selectedImage: UIImage? { get set }
}

final class ImageEditorViewModel: ImageEditorViewModelInterfaceType {
    @Published var selectedImage: UIImage? = nil
}

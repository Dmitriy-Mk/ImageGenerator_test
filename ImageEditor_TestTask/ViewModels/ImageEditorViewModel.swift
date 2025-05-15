//
// ImageEditorViewModel.swift
// ImageEditor_TestTask
//
// Created by Dmitriy Mk on 16.05.25.
//


import SwiftUI
import CoreImage
import CoreImage.CIFilterBuiltins

typealias ImageEditorViewModelInterfaceType = ObservableObject & ImageEditorViewModelInterface

protocol ImageEditorViewModelInterface: ObservableObject {
    var selectedImage: UIImage? { get set }
    var textOverlays: [TextOverlay] { get set }
    
    var filteredImage: UIImage? { get set }
    
    func applySepiaFilter(intensity: Double)
    func resetImageFilter()
}

final class ImageEditorViewModel: ImageEditorViewModelInterfaceType {
    @Published var selectedImage: UIImage? = nil {
        didSet {
            filteredImage = selectedImage
        }
    }
    
    @Published var textOverlays: [TextOverlay] = []
    
    @Published var filteredImage: UIImage? = nil
    
    private let context = CIContext()
    private let sepiaFilter = CIFilter.sepiaTone()
    
    func applySepiaFilter(intensity: Double = 1.0) {
        guard let inputImage = selectedImage,
              let ciInput = CIImage(image: inputImage) else {
            return
        }
        
        sepiaFilter.inputImage = ciInput
        sepiaFilter.intensity = Float(intensity)
        
        guard let ciOutput = sepiaFilter.outputImage,
              let cgImage = context.createCGImage(ciOutput, from: ciOutput.extent) else {
            return
        }
        
        filteredImage = UIImage(cgImage: cgImage)
    }
    
    func resetImageFilter() {
        filteredImage = selectedImage
    }
}

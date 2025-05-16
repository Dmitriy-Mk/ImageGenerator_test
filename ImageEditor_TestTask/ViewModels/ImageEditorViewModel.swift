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
    func applyFilter(name: String)
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
    private let mono = CIFilter.photoEffectMono()
    private let noir = CIFilter.photoEffectNoir()
    private let chrome = CIFilter.photoEffectChrome()
    private let fade = CIFilter.photoEffectFade()
    
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
    
    func applyFilter(name: String) {
        guard let input = selectedImage,
              let ciInput = CIImage(image: input) else { return }
        
        let filter: CIFilter? = {
            switch name {
            case "CIPhotoEffectMono":    return mono
            case "CIPhotoEffectNoir":    return noir
            case "CIPhotoEffectChrome":  return chrome
            case "CIPhotoEffectFade":    return fade
            default:                     return nil
            }
        }()
        
        filter?.setValue(ciInput, forKey: kCIInputImageKey)
        
        guard let output = filter?.outputImage,
              let cgImage = context.createCGImage(output, from: output.extent) else {
            return
        }
        filteredImage = UIImage(cgImage: cgImage)
    }
    
    func resetImageFilter() {
        filteredImage = selectedImage
    }
}

//
// ImageEditorViewModel.swift
// ImageEditor_TestTask
//
// Created by Dmitriy Mk on 16.05.25.
//


import SwiftUI
import CoreImage
import CoreImage.CIFilterBuiltins
import PencilKit
import Photos

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

extension ImageEditorViewModel {
    
    func renderFinalImage(canvasView: PKCanvasView, in size: CGSize) -> UIImage? {
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { ctx in
            
            if let base = filteredImage ?? selectedImage {
                base.draw(in: CGRect(origin: .zero, size: size))
            }
            
            let drawing = canvasView.drawing
            if !drawing.strokes.isEmpty {
                ctx.cgContext.translateBy(x: 0, y: size.height)
                ctx.cgContext.scaleBy(x: 1, y: -1)
                drawing.image(from: CGRect(origin: .zero, size: size),
                              scale: 1.0)
                .draw(in: CGRect(origin: .zero, size: size))
                ctx.cgContext.scaleBy(x: 1, y: -1)
                ctx.cgContext.translateBy(x: 0, y: -size.height)
            }
            
            for overlay in textOverlays {
                let attrs: [NSAttributedString.Key: Any] = [
                    .font: overlay.font.withSize(overlay.size),
                    .foregroundColor: UIColor(overlay.color)
                ]
                let attributed = NSAttributedString(
                    string: overlay.text,
                    attributes: attrs
                )
                
                let point = CGPoint(
                    x: overlay.offset.width + size.width/2,
                    y: overlay.offset.height + size.height/2
                )
                attributed.draw(at: point)
            }
        }
    }
}

extension ImageEditorViewModel {
    
    func saveToPhotoLibrary(
        canvasView: PKCanvasView,
        targetSize: CGSize,
        completion: @escaping (Result<Void,Error>) -> Void
    ) {
        guard let image = renderFinalImage(canvasView: canvasView, in: targetSize) else {
            completion(.failure(NSError(domain: "RenderError", code:0)))
            return
        }
        
        getPhotoLibraryAccess(image: image, completion: completion)
    }
    
    func getPhotoLibraryAccess(
        image: UIImage,
        completion: @escaping (
            Result<
            Void,
            Error
            >
        ) -> Void
    ) {
        PHPhotoLibrary.requestAuthorization { status in
            
            switch status {
            case .authorized:
                PHPhotoLibrary.shared().performChanges {
                    PHAssetChangeRequest.creationRequestForAsset(from: image)
                } completionHandler: { _, error in
                    DispatchQueue.main.async {
                        if let err = error {
                            completion(.failure(err))
                        } else {
                            completion(.success(()))
                        }
                    }
                }
                
            case .notDetermined:
                PHPhotoLibrary.requestAuthorization { newStatus in
                    DispatchQueue.main.async {
                        self.getPhotoLibraryAccess(image: image, completion: completion)
                    }
                }
                
            case .restricted, .denied, .limited:
                DispatchQueue.main.async {
                    let error = NSError(
                        domain: "PhotoLibraryAccess",
                        code: 1,
                        userInfo: [NSLocalizedDescriptionKey: "Access to Photo Library denied."]
                    )
                    completion(.failure(error))
                }
                
            @unknown default:
                DispatchQueue.main.async {
                    let error = NSError(
                        domain: "PhotoLibraryAccess",
                        code: 2,
                        userInfo: [NSLocalizedDescriptionKey: "Unknown authorization status."]
                    )
                    completion(.failure(error))
                }
                
            }
        }
    }
}

//
// ImageEditorViewModel.swift
// ImageEditor_TestTask
//
// Created by Dmitriy Mk on 16.05.25.
//

import SwiftUI
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
    func saveToPhotoLibrary(
        canvasView: PKCanvasView,
        targetSize: CGSize,
        completion: @escaping (Result<Void, Error>) -> Void
    )
    func renderFinalImage(canvasView: PKCanvasView, in size: CGSize) -> UIImage?
}

final class ImageEditorViewModel<PhotoLibViewModel>: ImageEditorViewModelInterfaceType
where PhotoLibViewModel: PhotoLibraryServiceType {

    @ObservedObject private var photoLibService: PhotoLibViewModel

    @Published var selectedImage: UIImage? {
        didSet {
            filteredImage = selectedImage
        }
    }
    @Published var textOverlays: [TextOverlay] = []
    @Published var filteredImage: UIImage?

    private let context = CIContext()
    private let sepiaFilter = CIFilter.sepiaTone()
    private let mono = CIFilter.photoEffectMono()
    private let noir = CIFilter.photoEffectNoir()
    private let chrome = CIFilter.photoEffectChrome()
    private let fade = CIFilter.photoEffectFade()

    init(photoLibService: PhotoLibViewModel) {
        self.photoLibService = photoLibService
    }

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
        photoLibService.renderFinalImage(
            canvasView: canvasView,
            filteredImage: filteredImage,
            selectedImage: selectedImage,
            textOverlays: textOverlays,
            in: size
        )
    }
}

extension ImageEditorViewModel {
    func saveToPhotoLibrary(
        canvasView: PKCanvasView,
        targetSize: CGSize,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        guard
            let image = renderFinalImage(canvasView: canvasView, in: targetSize)
        else {
            completion(.failure(NSError(domain: "RenderError", code: 0)))
            return
        }
        getPhotoLibraryAccess(image: image, completion: completion)
    }

    func getPhotoLibraryAccess(
        image: UIImage,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        photoLibService.getPhotoLibraryAccess(image: image, completion: completion)
    }
}

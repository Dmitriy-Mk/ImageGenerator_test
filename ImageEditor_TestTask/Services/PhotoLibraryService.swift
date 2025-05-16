//
// PhotoLibraryService.swift
// ImageEditor_TestTask
//
// Created by Dmitriy Mk on 13.05.25.
//

import UIKit
import Photos
import PencilKit

typealias PhotoLibraryServiceType = ObservableObject & PhotoLibraryServiceInterface

protocol PhotoLibraryServiceInterface {
    func getPhotoLibraryAccess(
        image: UIImage,
        completion: @escaping (Result<Void, Error>) -> Void
    )
    func renderFinalImage(
        canvasView: PKCanvasView,
        filteredImage: UIImage?,
        selectedImage: UIImage?,
        textOverlays: [TextOverlay],
        in size: CGSize
    ) -> UIImage?
}

final class PhotoLibraryService: PhotoLibraryServiceType {

    func getPhotoLibraryAccess(
        image: UIImage,
        completion: @escaping (Result<Void, Error>) -> Void
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
                PHPhotoLibrary.requestAuthorization { _ in
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

    func renderFinalImage(
        canvasView: PKCanvasView,
        filteredImage: UIImage?,
        selectedImage: UIImage?,
        textOverlays: [TextOverlay],
        in size: CGSize
    ) -> UIImage? {
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

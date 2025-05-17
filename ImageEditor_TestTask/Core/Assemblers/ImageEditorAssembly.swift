//
// ImageEditorAssembly.swift
// ImageEditor_TestTask
//
// Created by Dmitriy Mk on 16.05.25.
//

import Swinject

final class ImageEditorAssembly: Assembly {
    func assemble(container: Container) {
        container.register((any PhotoLibraryServiceType).self) { _ in
            PhotoLibraryService()
        }

        container.register((any ImageEditorViewModelInterface).self) { resolver in
            guard
                let photoService = resolver.resolve((any PhotoLibraryServiceType).self) as? PhotoLibraryService
            else {
                return ImageEditorViewModel(photoLibService: PhotoLibraryService())
            }

            return ImageEditorViewModel(photoLibService: photoService)
        }
        .inObjectScope(.container)
    }
}

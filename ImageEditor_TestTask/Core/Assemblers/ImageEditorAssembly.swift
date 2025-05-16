//
// ImageEditorAssembly.swift
// ImageEditor_TestTask
//
// Created by Dmitriy Mk on 16.05.25.
//

import Swinject

final class ImageEditorAssembly: Assembly {
    func assemble(container: Container) {
        container.register((any ImageEditorViewModelInterface).self) { _ in
            ImageEditorViewModel()
        }
        .inObjectScope(.container)
    }
}

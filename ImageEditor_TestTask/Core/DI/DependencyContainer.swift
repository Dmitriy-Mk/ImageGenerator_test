//
// DependencyContainer.swift
// ImageEditor_TestTask
//
// Created by Dmitriy Mk on 15.05.25.
//

import Swinject

final class DependencyContainer {
    static let shared = DependencyContainer()

    private let assembler: Assembler

    private init() {
        assembler = Assembler([
            AuthAssembly(),
            ImageEditorAssembly()
        ])
    }

    func resolve<T>(_ type: T.Type) -> T {
        guard let resolved = assembler.resolver.resolve(type) else {
            fatalError("⚠️ Can't resolve \(type)")
        }
        return resolved
    }
}

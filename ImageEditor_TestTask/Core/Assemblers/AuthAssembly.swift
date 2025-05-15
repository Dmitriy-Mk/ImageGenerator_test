//
// AuthAssembly.swift
// ImageEditor_TestTask
//
// Created by Dmitriy Mk on 15.05.25.
//


import Swinject

final class AuthAssembly: Assembly {
    func assemble(container: Container) {
        container.register(AuthServiceProtocol.self) { _ in
            AuthService()
        }.inObjectScope(.container)
        
        container.register((any AuthViewModelInterface).self) { resolver in
            let authService = resolver.resolve(AuthServiceProtocol.self)!
            return AuthViewModel(authService: authService)
        }
        .inObjectScope(.container)
    }
}

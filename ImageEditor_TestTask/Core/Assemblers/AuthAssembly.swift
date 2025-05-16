//
// AuthAssembly.swift
// ImageEditor_TestTask
//
// Created by Dmitriy Mk on 15.05.25.
//

import Swinject

final class AuthAssembly: Assembly {
    func assemble(container: Container) {
        container.register(AuthServiceProtocol.self) { _ in AuthService() }
            .inObjectScope(.container)

        container.register((any AuthViewModelInterface).self) { resolver in
            guard let svc = resolver.resolve(AuthServiceProtocol.self) else {
                return AuthViewModel(authService: AuthService())
            }
            return AuthViewModel(authService: svc)
        }
        .inObjectScope(.container)
    }
}

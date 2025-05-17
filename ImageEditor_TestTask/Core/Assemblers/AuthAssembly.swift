//
// AuthAssembly.swift
// ImageEditor_TestTask
//
// Created by Dmitriy Mk on 15.05.25.
//

import Swinject

final class AuthAssembly: Assembly {
    func assemble(container: Container) {
        container.register(AuthServiceInterface.self) { _ in AuthService() }
            .inObjectScope(.container)
        container.register(GoogleSignInServiceInterface.self) { _ in GoogleSignInService() }
            .inObjectScope(.container)

        container.register((any AuthViewModelInterface).self) { resolver in
            guard let svc = resolver.resolve(AuthServiceInterface.self),
                let gvc = resolver.resolve(GoogleSignInServiceInterface.self)
            else {
                return AuthViewModel(
                    authService: AuthService(),
                    googleSignInService: GoogleSignInService()
                )
            }
            return AuthViewModel(
                authService: svc,
                googleSignInService: gvc
            )
        }
        .inObjectScope(.container)
    }
}

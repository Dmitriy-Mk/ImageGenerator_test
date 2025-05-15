//
// SignUpViewModel.swift
// ImageEditor_TestTask
//
// Created by Dmitriy Mk on 13.05.25.
//


import SwiftUI
import Combine

typealias AuthViewModelType = ObservableObject & AuthViewModelInterface

protocol AuthViewModelInterface: ObservableObject {
    var appState: AppState { get set }
    var isLoading: Bool { get set }
    var errorMessage: String? { get set }
    var showSuccessMessage: Bool? { get set }

    func checkAuth()
    func signOut()
    func signInSuccessful()
    func signUpSuccessful()

    func signUp(email: String, password: String)
    func signIn(email: String, password: String)
    func resetPassword(email: String) -> AnyPublisher<Void, Error>
    func sendEmailVerification() -> AnyPublisher<Void, Error>
}

final class AuthViewModel: AuthViewModelInterface {
    // MARK: — Published properties
    @Published var appState: AppState = .onboarding
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    @Published var showSuccessMessage: Bool? = nil

    private var cancellables = Set<AnyCancellable>()
    private let authService: AuthServiceProtocol

    // MARK: — Init
    init(authService: AuthServiceProtocol) {
        self.authService = authService
        checkAuth()
    }

    // MARK: — Auth flow control
    func checkAuth() {
        if authService.checkCurrentUser() {
            appState = .editor
        } else {
            appState = .onboarding
        }
    }

    func signOut() {
        do {
            try authService.signOut()
        } catch {
            errorMessage = error.localizedDescription
        }
        appState = .onboarding
    }

    func signInSuccessful() {
        appState = .editor
    }
    
    func signUpSuccessful() {
        appState = .onboarding
    }

    // MARK: — Sign Up
    func signUp(email: String, password: String) {
        isLoading = true
        errorMessage = nil

        authService
            .signUpWithEmail(email: email, password: password)
            .flatMap { [weak self] _ -> AnyPublisher<Void, Error> in
                guard let self = self else {
                    return Fail(error: NSError(
                        domain: "AuthViewModel",
                        code: -1,
                        userInfo: nil
                    ))
                    .eraseToAnyPublisher()
                }
                return self.authService.sendEmailVerification()
            }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                self?.isLoading = false
                if case let .failure(error) = completion {
                    self?.errorMessage = error.localizedDescription
                }
            } receiveValue: { [weak self] in
                self?.showSuccessMessage = true
            }
            .store(in: &cancellables)
    }

    // MARK: — Sign In
    func signIn(email: String, password: String) {
        isLoading = true
        errorMessage = nil

        authService
            .signInWithEmail(email: email, password: password)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                self?.isLoading = false
                if case let .failure(error) = completion {
                    self?.errorMessage = error.localizedDescription
                }
            } receiveValue: { [weak self] _ in
                self?.showSuccessMessage = true
            }
            .store(in: &cancellables)
    }

    // MARK: — Reset Password
    func resetPassword(email: String) -> AnyPublisher<Void, Error> {
        authService
            .resetPassword(email: email)
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }

    // MARK: — Email Verification
    func sendEmailVerification() -> AnyPublisher<Void, Error> {
        authService
            .sendEmailVerification()
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
}

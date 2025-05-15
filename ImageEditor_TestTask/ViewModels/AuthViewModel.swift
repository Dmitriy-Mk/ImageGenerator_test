//
// SignUpViewModel.swift
// ImageEditor_TestTask
//
// Created by Dmitriy Mk on 13.05.25.
//


import SwiftUI
import Combine

typealias ViewModelType = ObservableObject & AuthViewModelInterface

protocol AuthViewModelInterface: ObservableObject {
    
    var appState: AppState { get }
    var isLoading: Bool { get set }
    var errorMessage: String? { get set }
    var showSuccessMessage: Bool? { get set }
    
    func signUp(email: String, password: String)
    func signIn(email: String, password: String)
    func resetPassword(email: String)
    func sendEmailVerification() -> AnyPublisher<Void, Error>
}

final class AuthViewModel: AuthViewModelInterface {
    
    @Published var appState: AppState = .onboarding
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    @Published var showSuccessMessage: Bool? = nil
    
    private var cancellables: Set<AnyCancellable> = []
    
    private let authService: AuthServiceProtocol
    
    public init(authService: AuthServiceProtocol) {
        self.authService = authService
        checkAuth()
    }
    
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
            print(error.localizedDescription)
        }
        
        appState = .onboarding
    }
    
    func signInSuccessful() {
        appState = .editor
    }
    
    func signUp(email: String, password: String) {
        isLoading = true
        errorMessage = nil
        
        authService
            .signUpWithEmail(email: email, password: password)
            .flatMap { [weak self] _ -> AnyPublisher<Void, Error> in
                guard let self = self else {
                    return Fail(error: NSError(domain: "", code: -1, userInfo: nil))
                        .eraseToAnyPublisher()
                }
                return self.authService.sendEmailVerification()
            }
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                self?.isLoading = false
                if case let .failure(error) = completion {
                    self?.errorMessage = error.localizedDescription
                }
            }, receiveValue: { [weak self] _ in
                self?.showSuccessMessage = true
            })
            .store(in: &cancellables)
    }
    
    func signIn(email: String, password: String) {
        authService.signInWithEmail(email: email, password: password)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                self?.isLoading = false
                if case let .failure(error) = completion {
                    self?.errorMessage = error.localizedDescription
                }
            }, receiveValue: { [weak self] _ in
                // Показываем Alert с текстом "Вы успешно вошли в  аккаунт"
                // Открываем экран ImageEditor
                self?.showSuccessMessage = true
            })
            .store(in: &cancellables)
    }
    
    func resetPassword(email: String) {
        authService.resetPassword(email: email)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                self?.isLoading = false
                
                switch completion {
                case .finished:
                    self?.showSuccessMessage = true
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                }
            } receiveValue: { _ in }
            .store(in: &cancellables)
    }
    
    func sendEmailVerification() -> AnyPublisher<Void, Error> {
        authService.sendEmailVerification()
    }
}

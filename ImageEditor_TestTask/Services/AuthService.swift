//
// AuthService.swift
// ImageEditor_TestTask
//
// Created by Dmitriy Mk on 13.05.25.
//

import FirebaseAuth
import Combine

final class AuthService {
    
    static let shared = AuthService()
    
    func signInWithEmail(email: String, password: String) -> AnyPublisher<User, Error> {
        Future { promise in
            Auth.auth().signIn(withEmail: email, password: password) { result, error in
                if let user = result?.user {
                    promise(.success(User(uid: user.uid, email: user.email!)))
                } else {
                    promise(.failure(error!))
                }
            }
        }
        .eraseToAnyPublisher()
    }
    // Аналогично: signUp, resetPassword, sendEmailVerification
}

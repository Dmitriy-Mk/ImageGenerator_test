//
// GoogleSignInService.swift
// ImageEditor_TestTask
//
// Created by Dmitriy Mk on 15.05.25.
//

import FirebaseAuth
import Combine

protocol AuthServiceInterface {
    func signInWithEmail(email: String, password: String) -> AnyPublisher<User, Error>
    func signUpWithEmail(email: String, password: String) -> AnyPublisher<User, Error>
    func resetPassword(email: String) -> AnyPublisher<Void, Error>
    func sendEmailVerification() -> AnyPublisher<Void, Error>
    func checkCurrentUser() -> Bool
    func signOut() throws
}

final class AuthService: AuthServiceInterface {

    /// Signs in the user to their account.
    ///
    /// Uses Firebase Auth to authenticate with email and password.
    ///
    /// - Parameters:
    ///   - email: The user's email address.
    ///   - password: The user's password.
    /// - Returns: A publisher that emits a `User` on successful authentication or an error.
    /// 
    func signInWithEmail(email: String, password: String) -> AnyPublisher<User, Error> {
        Future { promise in
            Auth.auth().signIn(withEmail: email, password: password) { result, error in
                if let user = result?.user {
                    promise(.success(User(uid: user.uid, email: user.email ?? "")))
                } else {
                    promise(.failure(error ?? AuthServiceError.unknownError))
                }
            }
        }
        .eraseToAnyPublisher()
    }

    /// Registers a new user with email and password.
    ///
    /// Uses Firebase Auth to create a new account.
    ///
    /// - Parameters:
    ///   - email: The user's email address.
    ///   - password: The user's password.
    /// - Returns: A publisher that emits a `User` on successful registration or an error.
    func signUpWithEmail(email: String, password: String) -> AnyPublisher<User, Error> {
        Future { promise in
            Auth.auth().createUser(withEmail: email, password: password) { result, error in
                if let result = result {
                    promise(.success(User(uid: result.user.uid, email: result.user.email ?? "")))
                } else {
                    promise(.failure(error ?? AuthServiceError.unknownError))
                }
            }
        }
        .eraseToAnyPublisher()
    }

    /// Sends a password reset email.
    ///
    /// Uses Firebase Auth to send password reset instructions to the provided email.
    ///
    /// - Parameter email: The user's email address.
    /// - Returns: A publisher that completes successfully or emits an error.
    func resetPassword(email: String) -> AnyPublisher<Void, Error> {
        Future { promise in
            Auth.auth().sendPasswordReset(withEmail: email) { error in
                if let error = error {
                    promise(.failure(error))
                } else {
                    promise(.success(()))
                }
            }
        }
        .eraseToAnyPublisher()
    }

    /// Sends an email verification link.
    ///
    /// Used after user registration to confirm the email address via a link.
    ///
    /// - Returns: A publisher that completes successfully or emits an error.
    func sendEmailVerification() -> AnyPublisher<Void, Error> {
        guard let user = Auth.auth().currentUser else {
            return Fail(error: NSError(
                domain: "AuthService",
                code: 0,
                userInfo: [NSLocalizedDescriptionKey: "User is not authenticated"]
            ))
            .eraseToAnyPublisher()
        }
        return Future { promise in
            user.sendEmailVerification { error in
                if let error = error {
                    promise(.failure(error))
                } else {
                    promise(.success(()))
                }
            }
        }
        .eraseToAnyPublisher()
    }

    func checkCurrentUser() -> Bool {
        return Auth.auth().currentUser != nil
    }

    func signOut() throws {
        try? Auth.auth().signOut()
    }
}

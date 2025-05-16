//
// GoogleSignInService.swift
// ImageEditor_TestTask
//
// Created by Dmitriy Mk on 13.05.25.
//

import GoogleSignIn
import GoogleSignInSwift
import Combine
import FirebaseCore
import FirebaseAuth

protocol GoogleSignInServiceInterface {
    func signInWithGoogle(presentingViewController: UIViewController) -> AnyPublisher<User, Error>
}

/// Service responsible for handling Google Sign-In using Firebase authentication.
final class GoogleSignInService: GoogleSignInServiceInterface {

    /// Signs in a user using their Google account.
    ///
    /// This method initiates the Google Sign-In flow and authenticates the user
    /// with Firebase using the retrieved Google credentials.
    ///
    /// - Parameter presentingViewController: The view controller that will present the Google Sign-In flow.
    /// - Returns: A publisher that emits a `User` object on successful authentication or an error if the process fails.
    ///
    /// The flow performs the following steps:
    /// 1. Retrieves the `clientID` from Firebase configuration.
    /// 2. Configures the `GIDSignIn` instance with this client ID.
    /// 3. Starts the Google Sign-In flow using the provided view controller.
    /// 4. Extracts the `idToken` and `accessToken` from the result.
    /// 5. Creates a Firebase `AuthCredential` using the Google tokens.
    /// 6. Signs in to Firebase with this credential.
    ///
    /// Possible failure reasons include:
    /// - Missing `clientID` in Firebase configuration.
    /// - Error returned by Google Sign-In.
    /// - Missing tokens in the sign-in result.
    /// - Failure during Firebase authentication.
    func signInWithGoogle(presentingViewController: UIViewController) -> AnyPublisher<User, Error> {
        Future { promise in
            guard let clientID = FirebaseApp.app()?.options.clientID else {
                promise(
                    .failure(
                        NSError(domain: "AuthService", code: -1,
                                userInfo: [NSLocalizedDescriptionKey: "Failed to fetch clientID"])
                    )
                )
                return
            }

            let config = GIDConfiguration(clientID: clientID)
            GIDSignIn.sharedInstance.configuration = config

            GIDSignIn.sharedInstance.signIn(withPresenting: presentingViewController) { result, error in
                if let error = error {
                    promise(.failure(error))
                    return
                }

                guard
                    let user = result?.user,
                    let idToken = user.idToken?.tokenString
                else {
                    promise(
                        .failure(
                            NSError(domain: "AuthService", code: -1,
                                    userInfo: [NSLocalizedDescriptionKey: "Failed to fetch tokens"])
                        )
                    )
                    return
                }

                let accessToken = user.accessToken.tokenString
                let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: accessToken)

                Auth.auth().signIn(with: credential) { authResult, error in
                    if let error = error {
                        promise(.failure(error))
                    } else if let user = authResult?.user {
                        promise(.success(User(uid: user.uid, email: user.email ?? "")))
                    } else {
                        promise(
                            .failure(
                                NSError(domain: "AuthService", code: -1,
                                        userInfo: [NSLocalizedDescriptionKey: "Undefined error"])
                            )
                        )
                    }
                }
            }
        }
        .eraseToAnyPublisher()
    }
}

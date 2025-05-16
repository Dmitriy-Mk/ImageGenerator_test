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

final class GoogleSignInService: GoogleSignInServiceInterface {

    func signInWithGoogle(presentingViewController: UIViewController) -> AnyPublisher<User, Error> {
        Future { promise in
            guard let clientID = FirebaseApp.app()?.options.clientID else {
                promise(
                    .failure(
                        NSError(domain: "AuthService", code: -1,
                                userInfo: [NSLocalizedDescriptionKey: "Не удалось получить clientID"])
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
                                    userInfo: [NSLocalizedDescriptionKey: "Не удалось получить токены"])
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
                                        userInfo: [NSLocalizedDescriptionKey: "Неизвестная ошибка"])
                            )
                        )
                    }
                }
            }
        }
        .eraseToAnyPublisher()
    }
}

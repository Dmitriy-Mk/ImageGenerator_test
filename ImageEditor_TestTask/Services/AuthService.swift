import FirebaseAuth
import Combine

protocol AuthServiceProtocol {
    func signInWithEmail(email: String, password: String) -> AnyPublisher<User, Error>
    func signUpWithEmail(email: String, password: String) -> AnyPublisher<User, Error>
    func resetPassword(email: String) -> AnyPublisher<Void, Error>
    func sendEmailVerification() -> AnyPublisher<Void, Error>
    func checkCurrentUser() -> Bool
    func signOut() throws
}

final class AuthService: AuthServiceProtocol {

    /// Выполняет вход пользователя в его аккаунт.
    ///
    /// Использует Firebase Auth для аутентификации по email и паролю.
    ///
    /// - Parameters:
    ///   - email: Адрес электронной почты пользователя.
    ///   - password: Пароль пользователя.
    /// - Returns: Паблишер, который возвращает объект `User` при успешной аутентификации или ошибку.
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

    /// Регистрирует нового пользователя по email и паролю.
    ///
    /// Использует Firebase Auth для создания новой учетной записи.
    ///
    /// - Parameters:
    ///   - email: Адрес электронной почты пользователя.
    ///   - password: Пароль пользователя.
    /// - Returns: Паблишер, который возвращает объект `User` при успешной регистрации или ошибку.
    func signUpWithEmail(email: String, password: String) -> AnyPublisher<User, Error> {
        Future { promise in
            Auth.auth().createUser(withEmail: email, password: password) { result, error in
                if let result = result {
                    promise(.success(User(uid: result.user.uid, email: result.user.email!)))
                } else {
                    promise(.failure(error!))
                }
            }
        }
        .eraseToAnyPublisher()
    }

    /// Отправляет письмо со ссылкой для сброса пароля.
    ///
    /// Использует Firebase Auth для отправки инструкции по сбросу пароля на указанный email.
    ///
    /// - Parameter email: Адрес электронной почты пользователя.
    /// - Returns: Паблишер, который завершится успешно или вернёт ошибку.
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

    /// Отправляет письмо с подтверждением email-адреса.
    ///
    /// Используется после регистрации пользователя для подтверждения почты через ссылку.
    ///
    /// - Returns: Паблишер, который завершится успешно или вернёт ошибку.
    func sendEmailVerification() -> AnyPublisher<Void, Error> {
        guard let user = Auth.auth().currentUser else {
            return Fail(error: NSError(
                domain: "AuthService",
                code: 0,
                userInfo: [NSLocalizedDescriptionKey: "Пользователь не авторизован"]
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

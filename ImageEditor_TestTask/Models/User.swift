//
// User.swift
// ImageEditor_TestTask
//
// Created by Dmitriy Mk on 13.05.25.
//


import Foundation


/// Структура, представляющая пользователя, авторизованного в приложении.
///
/// Используется для хранения минимального набора данных, полученных после регистрации
/// или входа через Firebase Auth. Может быть расширена дополнительной информацией
/// (например, displayName, isEmailVerified и т.д.).
public struct User {
    
    /// Уникальный идентификатор пользователя, присвоенный Firebase.
    public let uid: String

    /// Адрес электронной почты, связанный с аккаунтом пользователя.
    public let email: String
}

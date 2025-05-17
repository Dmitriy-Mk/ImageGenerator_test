//
// ErrorsList.swift
// ImageEditor_TestTask
//
// Created by Dmitriy Mk on 17.05.25.
//

import Foundation

enum AuthServiceError: LocalizedError {
    case unknownError

    var errorDescription: String? {
        switch self {
        case .unknownError:
            return NSLocalizedString("Unknown error while trying to log in", comment: "")
        }
    }

    var errorCode: Int {
        switch self {
        case .unknownError:
            return 1001
        }
    }
}

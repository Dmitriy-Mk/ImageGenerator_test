//
// UIApplication+FirstKeyWindow.swift
// ImageEditor_TestTask
//
// Created by Dmitriy Mk on 16.05.25.
//

import UIKit

extension UIApplication {

    var firstKeyWindow: UIWindow? {

        let windowScenes = connectedScenes
            .compactMap { $0 as? UIWindowScene }

        let activeScenes = windowScenes
            .filter { $0.activationState == .foregroundActive }

        guard let scene = activeScenes.first else { return nil }

        return scene.windows.first { $0.isKeyWindow }
    }

    var rootViewController: UIViewController? {
        firstKeyWindow?.rootViewController
    }
}

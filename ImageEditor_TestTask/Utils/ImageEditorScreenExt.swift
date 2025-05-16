//
// ImageEditorScreenExt.swift
// ImageEditor_TestTask
//
// Created by Dmitriy Mk on 16.05.25.
//

import SwiftUI
import AVFoundation

extension ImageEditorScreen {
    func checkCameraPermission(completion: @escaping (Bool) -> Void) {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            completion(true)
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                DispatchQueue.main.async { completion(granted) }
            }
        default:
            completion(false)
        }
    }
}

//
// AppDelegate.swift
// ImageEditor_TestTask
//
// Created by Dmitriy Mk on 15.05.25.
//


import UIKit
import FirebaseCore

class AppDelegate: UIResponder, UIApplicationDelegate {
    
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        
        FirebaseApp.configure()
        return true
    }
}

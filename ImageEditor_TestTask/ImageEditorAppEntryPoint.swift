//
// ImageEditor_TestTaskApp.swift
// ImageEditor_TestTask
//
// Created by Dmitriy Mk on 13.05.25.
//

import SwiftUI
import Swinject

@main
struct ImageEditorTestTaskApp: App {

    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup {
            let authViewModel = DependencyContainer.shared.resolve(
                (any AuthViewModelInterface).self
            ) as? AuthViewModel

            let editorViewModel = DependencyContainer.shared.resolve(
                (any ImageEditorViewModelInterface).self
            ) as? ImageEditorViewModel<PhotoLibraryService>

            ContentView(authViewModel: authViewModel!, editorViewModel: editorViewModel!)
        }
    }
}

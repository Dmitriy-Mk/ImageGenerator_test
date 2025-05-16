//
// ShareSheet.swift
// ImageEditor_TestTask
//
// Created by Dmitriy Mk on 16.05.25.
//


import SwiftUI
import UIKit

struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]

    func makeUIViewController(context: Context)
        -> UIActivityViewController
    {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }
    func updateUIViewController(_ uiViewController: UIActivityViewController,
                                context: Context) { }
}

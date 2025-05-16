//
// TextOverlay.swift
// ImageEditor_TestTask
//
// Created by Dmitriy Mk on 16.05.25.
//


import SwiftUI

struct TextOverlay: Identifiable {
    let id = UUID()
    var text: String
    var font: UIFont
    var color: Color
    var size: CGFloat
    var offset: CGSize = .zero
}

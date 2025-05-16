//
// UIimage+Identifiable.swift
// ImageEditor_TestTask
//
// Created by Dmitriy Mk on 16.05.25.
//


import UIKit

extension UIImage: @retroactive Identifiable {
    public var id: String { self.pngData()?.base64EncodedString() ?? UUID().uuidString }
}

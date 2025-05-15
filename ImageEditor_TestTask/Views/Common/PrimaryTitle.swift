//
// TitleTextView.swift
// ImageEditor_TestTask
//
// Created by Dmitriy Mk on 15.05.25.
//


import SwiftUI

struct PrimaryTitle: View {
    let text: String
    let textSize: CGFloat
    
    init(text: String, textSize: CGFloat = 24) {
        self.text = text
        self.textSize = textSize
    }

    var body: some View {
        Text(text)
            .font(.largeTitle)
            .bold()
            .padding(.bottom, textSize)
    }
}

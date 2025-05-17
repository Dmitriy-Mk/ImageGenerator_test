//
// PrimaryProgressView.swift
// ImageEditor_TestTask
//
// Created by Dmitriy Mk on 15.05.25.
//

import SwiftUI

struct PrimaryProgressView: View {

    let title: String

    var body: some View {
        ProgressView(title)
            .modifier(PrimaryProgressViewStyle())
    }
}

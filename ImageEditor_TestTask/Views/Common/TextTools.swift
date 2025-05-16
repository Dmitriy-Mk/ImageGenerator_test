//
// TextTools.swift
// ImageEditor_TestTask
//
// Created by Dmitriy Mk on 16.05.25.
//


import SwiftUI

struct TextTools<ViewModel>: View
where ViewModel: ImageEditorViewModelInterfaceType
{
    
    @State var newText: String
    @State var selectedFont: Font
    @State var selectedSize: CGFloat
    @State var selectedColor: Color
    @StateObject var viewModel: ViewModel
    
    var body: some View {
        VStack(spacing: 8) {
            HStack {
                TextField("Enter text", text: $newText)
                    .textFieldStyle(.roundedBorder)
                    .frame(maxWidth: 180)
                
                Button("Add") {
                    let uiFont: UIFont
                    switch selectedFont {
                    case .title: uiFont = UIFont.preferredFont(forTextStyle: .title1)
                    case .body: uiFont = UIFont.preferredFont(forTextStyle: .body)
                    default: uiFont = UIFont.systemFont(ofSize: selectedSize)
                    }
                    
                    let overlay = TextOverlay(
                        text: newText,
                        font: uiFont,
                        color: selectedColor,
                        size: selectedSize
                    )
                    viewModel.textOverlays.append(overlay)
                    newText = ""
                }
                .disabled(newText.isEmpty)
            }
            
            HStack {
                Menu("Font") {
                    Button("Title") { selectedFont = .title }
                    Button("Body") { selectedFont = .body }
                }
                
                ColorPicker("Color", selection: $selectedColor)
                
                Slider(value: $selectedSize, in: 12...72) {
                    Text("Size")
                }
                .frame(width: 120)
            }
        }
    }
}

//
// TextTools.swift
// ImageEditor_TestTask
//
// Created by Dmitriy Mk on 16.05.25.
//

import SwiftUI

struct TextTools<ViewModel>: View
where ViewModel: ImageEditorViewModelInterfaceType {

    @State var newText: String
    @State var selectedFont: Font
    @State var selectedSize: CGFloat
    @State var selectedColor: Color
    @StateObject var viewModel: ViewModel

    var body: some View {
        VStack(spacing: 18) {
            HStack(spacing: 10) {
                TextField("Enter text", text: $newText)
                    .padding(.horizontal, 12)
                    .frame(height: ImageEditorConstants.textFieldHeight)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.gray.opacity(0.6), lineWidth: 1)
                    )
                    .font(.system(size: ImageEditorConstants.textFieldFontSize))
                    .frame(width: 180)

                Button("Add") {
                    let uiFont: UIFont
                    switch selectedFont {
                    case .title:
                        uiFont = UIFont.systemFont(ofSize: selectedSize, weight: .bold)
                    case .body:
                        uiFont = UIFont.systemFont(ofSize: selectedSize, weight: .regular)
                    default:
                        uiFont = UIFont.systemFont(ofSize: selectedSize)
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
                .font(.system(size: ImageEditorConstants.textFieldFontSize))
                .frame(width: ImageEditorConstants.addButtonWidth, height: ImageEditorConstants.buttonHeight)
                .disabled(newText.isEmpty)
            }

            HStack {
                Menu {
                    Button("Title") { selectedFont = .title }
                    Button("Body") { selectedFont = .body }
                } label: {
                    Label("Font", systemImage: "textformat")
                        .font(.system(size: ImageEditorConstants.buttonHeight))
                        .frame(width: ImageEditorConstants.buttonWidth, height: ImageEditorConstants.buttonHeight)
                }

                ColorPicker("", selection: $selectedColor)
                    .font(.system(size: ImageEditorConstants.buttonHeight))
                    .frame(width: ImageEditorConstants.buttonWidth, height: ImageEditorConstants.buttonHeight)

                Slider(value: $selectedSize, in: 12...72) {
                    Text("Size")
                }
                .frame(width: 120)
            }
        }
    }
}

#Preview {
    TextTools(
        newText: "",
        selectedFont: .body,
        selectedSize: 0,
        selectedColor: .red,
        viewModel: ImageEditorViewModel(photoLibService: PhotoLibraryService())
    )
}

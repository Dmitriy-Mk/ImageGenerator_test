//
// ConstantsEnum.swift
// ImageEditor_TestTask
//
// Created by Dmitriy Mk on 15.05.25.
//

import UIKit

enum MainConstants: CGFloat {
    case textFieldHorizontalPadding = 20.0
    case primaryVerticalPadding = 0.0
    case secondaryVerticalPadding = 16.0
}

let isPad: Bool = UIDevice.current.userInterfaceIdiom == .pad

struct Constants {
    static let textFieldFontSize: CGFloat = isPad ? 22 : 17
    static let textFieldHeight: CGFloat = isPad ? 45 : 30
    static var instrumentsSpacing: CGFloat { UIDevice.current.userInterfaceIdiom == .pad ? 55 : 30 }
    static var buttonHeight: CGFloat { UIDevice.current.userInterfaceIdiom == .pad ? 40 : 27 }
    static var buttonWidth: CGFloat { UIDevice.current.userInterfaceIdiom == .pad ? 60 : 35 }
    static var addButtonWidth: CGFloat { UIDevice.current.userInterfaceIdiom == .pad ? 55 : 40 }
    static var addButtonHeight: CGFloat { UIDevice.current.userInterfaceIdiom == .pad ? 45 : 30 }
}

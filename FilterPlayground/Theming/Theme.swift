//
//  Theme.swift
//  FilterPlayground
//
//  Created by Leo Thomas on 05.08.17.
//  Copyright © 2017 Leo Thomas. All rights reserved.
//

#if os(iOS) || os(tvOS)
    import UIKit
    typealias Color = UIColor
#else
    import Cocoa
    typealias Color = NSColor
#endif

protocol Theme {
    static var sourceEditorBackground: Color { get }
    static var sourceEditorLineNumber: Color { get }
    static var sourceEditorLineBackgroundError: Color { get }
    static var sourceEditorLineBackgroundHighlighted: Color { get }
    static var sourceEditTextComment: Color { get }
    static var sourceEditorTextType: Color { get }
    static var sourceEditorTextKeyword: Color { get }
    static var sourceEditorTextFloat: Color { get }
    static var sourceEditorText: Color { get }
    static var liveViewBackground: Color { get }
    static var liveViewLabel: Color { get }
    static var dropInteractionBorder: Color { get }
    static var imageViewBackground: Color { get }
    static var attributesSeparatorColor: Color { get }
    static var attributesBackground: Color { get }
    static var attributesCellBackground: Color { get }
}

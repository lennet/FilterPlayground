//
//  Theme.swift
//  FilterPlayground
//
//  Created by Leo Thomas on 05.08.17.
//  Copyright © 2017 Leo Thomas. All rights reserved.
//

import UIKit

protocol Theme {
    static var sourceEditorBackground: UIColor { get }
    static var sourceEditorLineNumber: UIColor { get }
    static var sourceEditorLineBackgroundError: UIColor { get }
    static var sourceEditorLineBackgroundHighlighted: UIColor { get }
    static var sourceEditTextComment: UIColor { get }
    static var sourceEditorTextType: UIColor { get }
    static var sourceEditorTextKeyword: UIColor { get }
    static var sourceEditorTextFloat: UIColor { get }
    static var sourceEditorText: UIColor { get }
    static var liveViewBackground: UIColor { get }
    static var liveViewLabel: UIColor { get }
    static var dropInteractionBorder: UIColor { get }
    static var imageViewBackground: UIColor { get }
    static var attributesSeparatorColor: UIColor { get }
    static var attributesBackground: UIColor { get }
    static var attributesCellBackground: UIColor { get }
}

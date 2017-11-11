//
//  NightTheme.swift
//  FilterPlayground
//
//  Created by Leo Thomas on 10.11.17.
//  Copyright © 2017 Leo Thomas. All rights reserved.
//

import UIKit

struct NightTheme: Theme {
    static var attributesCellBackground: UIColor = .black

    static var attributesSeparatorColor: UIColor = .white

    static var attributesBackground: UIColor = .black

    static var sourceEditTextComment: UIColor = .green

    static var sourceEditorTextFloat: UIColor = .blue

    static var sourceEditorText: UIColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)

    static var sourceEditorTextType: UIColor = .purple

    static var sourceEditorTextKeyword: UIColor = .red

    static var sourceEditorLineBackgroundError: UIColor = UIColor.red.withAlphaComponent(0.1)

    static var sourceEditorLineBackgroundHighlighted: UIColor = UIColor.blue.withAlphaComponent(0.1)

    static var sourceEditorBackground: UIColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)

    static var sourceEditorLineNumber: UIColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)

    static var liveViewBackground: UIColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)

    static var liveViewLabel: UIColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)

    static var dropInteractionBorder: UIColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)

    static var imageViewBackground: UIColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
}

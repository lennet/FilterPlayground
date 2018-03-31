//
//  DefaultTheme.swift
//  FilterPlayground
//
//  Created by Leo Thomas on 10.11.17.
//  Copyright © 2017 Leo Thomas. All rights reserved.
//

import Foundation

struct Default: Theme {
    static var sourceEditTextComment: Color = #colorLiteral(red: 0.4666666687, green: 0.7647058964, blue: 0.2666666806, alpha: 1)

    static var sourceEditorTextFloat: Color = #colorLiteral(red: 0.1764705926, green: 0.4980392158, blue: 0.7568627596, alpha: 1)

    static var sourceEditorText: Color = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)

    static var sourceEditorTextType: Color = #colorLiteral(red: 0.5725490451, green: 0, blue: 0.2313725501, alpha: 1)

    static var sourceEditorTextKeyword: Color = #colorLiteral(red: 0.9254902005, green: 0.2352941185, blue: 0.1019607857, alpha: 1)

    static var sourceEditorLineBackgroundError: Color = #colorLiteral(red: 1, green: 0.231372549, blue: 0.1882352941, alpha: 0.2044360017)

    static var sourceEditorLineBackgroundHighlighted: Color = #colorLiteral(red: 0.1058823529, green: 0.6784313725, blue: 0.9725490196, alpha: 0.1)

    static var sourceEditorBackground: Color = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)

    static var sourceEditorLineNumber: Color = #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1)

    static var liveViewBackground: Color = #colorLiteral(red: 0.9404068964, green: 0.9404068964, blue: 0.9404068964, alpha: 1)

    static var liveViewLabel: Color = #colorLiteral(red: 0.3333333433, green: 0.3333333433, blue: 0.3333333433, alpha: 1)

    static var dropInteractionBorder: Color = #colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1)

    static var imageViewBackground: Color = #colorLiteral(red: 0.8214625635, green: 0.8214625635, blue: 0.8214625635, alpha: 1)

    static var attributesSeparatorColor: Color = .darkGray

    static var attributesBackground: Color = .white

    static var attributesCellBackground: Color = .white
}

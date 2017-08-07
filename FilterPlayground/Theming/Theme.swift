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
}

struct NightTheme: Theme {
    static var sourceEditTextComment: UIColor = .green
    
    static var sourceEditorTextFloat: UIColor = .blue
    
    static var sourceEditorText: UIColor = .black
    
    static var sourceEditorTextType: UIColor = .purple
    
    static var sourceEditorTextKeyword: UIColor = .red
    
    static var sourceEditorLineBackgroundError: UIColor = UIColor.red.withAlphaComponent(0.1)
    
    static var sourceEditorLineBackgroundHighlighted: UIColor = UIColor.blue.withAlphaComponent(0.1)
    
    static var sourceEditorBackground: UIColor = .black
    
    static var sourceEditorLineNumber: UIColor = .black
    
    static var liveViewBackground: UIColor = #colorLiteral(red: 0.8000000119, green: 0.8000000119, blue: 0.8000000119, alpha: 1)
}

struct Default: Theme {
    static var sourceEditTextComment: UIColor = #colorLiteral(red: 0.4666666687, green: 0.7647058964, blue: 0.2666666806, alpha: 1)
    
    static var sourceEditorTextFloat: UIColor = #colorLiteral(red: 0.1764705926, green: 0.4980392158, blue: 0.7568627596, alpha: 1)
    
    static var sourceEditorText: UIColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
    
    static var sourceEditorTextType: UIColor = #colorLiteral(red: 0.5725490451, green: 0, blue: 0.2313725501, alpha: 1)
    
    static var sourceEditorTextKeyword: UIColor = #colorLiteral(red: 0.9254902005, green: 0.2352941185, blue: 0.1019607857, alpha: 1)

    static var sourceEditorLineBackgroundError: UIColor = #colorLiteral(red: 1, green: 0.231372549, blue: 0.1882352941, alpha: 0.2044360017)
    
    static var sourceEditorLineBackgroundHighlighted: UIColor = #colorLiteral(red: 0.1058823529, green: 0.6784313725, blue: 0.9725490196, alpha: 0.1972923801)

    static var sourceEditorBackground: UIColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
    
    static var sourceEditorLineNumber: UIColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
    
    static var liveViewBackground: UIColor = #colorLiteral(red: 0.9404068964, green: 0.9404068964, blue: 0.9404068964, alpha: 1)
}

class ThemeManager {
    
    static let themeChangedNotificationName = Notification.Name("themeChangedNotificationName")
    static let shared: ThemeManager = ThemeManager()
    
    var currentTheme: Theme.Type = Default.self {
        didSet {
            NotificationCenter.default.post(name: ThemeManager.themeChangedNotificationName, object: currentTheme)
        }
    }
    
    private init() {}
}



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
}

struct Default: Theme {
    static var sourceEditTextComment: UIColor = .green
    
    static var sourceEditorTextFloat: UIColor = .blue
    
    static var sourceEditorText: UIColor = .black
    
    static var sourceEditorTextType: UIColor = .purple
    
    static var sourceEditorTextKeyword: UIColor = .red

    static var sourceEditorLineBackgroundError: UIColor = UIColor.red.withAlphaComponent(0.1)
    
    static var sourceEditorLineBackgroundHighlighted: UIColor = UIColor.blue.withAlphaComponent(0.1)

    static var sourceEditorBackground: UIColor = .white
    
    static var sourceEditorLineNumber: UIColor = .black
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



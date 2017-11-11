//
//  ThemeManager.swift
//  FilterPlayground
//
//  Created by Leo Thomas on 10.11.17.
//  Copyright © 2017 Leo Thomas. All rights reserved.
//

import Foundation

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

//
//  Settings.swift
//  FilterPlayground
//
//  Created by Leo Thomas on 12.09.17.
//  Copyright © 2017 Leo Thomas. All rights reserved.
//

import Foundation

struct Settings {
    static var tabsEnabled: Bool {
        get {
            return UserDefaults.standard.bool(forKey: #function)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: #function)
        }
    }

    static var fontSize: Float {
        get {
            guard UserDefaults.standard.value(forKey: #function) != nil else {
                return 12
            }
            return UserDefaults.standard.float(forKey: #function)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: #function)
        }
    }

    static let customFrameRateChangedNotificationName = NSNotification.Name("CustomFrameRateSettingChangedNotification")
    static var customFrameRate: Int? {
        get {
            guard UserDefaults.standard.value(forKey: #function) != nil else {
                return nil
            }
            return UserDefaults.standard.integer(forKey: #function)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: #function)
            NotificationCenter.default.post(name: customFrameRateChangedNotificationName, object: newValue)
        }
    }

    static let ignoreLowPowerModeChangedNotificationName = NSNotification.Name("IgnoreLowPowerModeSettingChangedNotification")
    static var ignoreLowPowerMode: Bool {
        get {
            return UserDefaults.standard.bool(forKey: #function)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: #function)
            NotificationCenter.default.post(name: ignoreLowPowerModeChangedNotificationName, object: newValue)
        }
    }

    static let showStatisticsChangedNotificationName = NSNotification.Name("ShowStatisticsSettingChangedNotification")
    static var showStatistics: Bool {
        get {
            return UserDefaults.standard.bool(forKey: #function)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: #function)
            NotificationCenter.default.post(name: showStatisticsChangedNotificationName, object: newValue)
        }
    }

    static var spacingValue: String {
        return tabsEnabled ? "\t" : "    "
    }

    #if DEBUG
        static var enableExperimentalFeatures: Bool {
            get {
                return UserDefaults.standard.bool(forKey: #function)
            }
            set {
                UserDefaults.standard.set(newValue, forKey: #function)
            }
        }
    #endif
}

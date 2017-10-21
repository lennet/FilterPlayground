//
//  FrameRateManager.swift
//  FilterPlayground
//
//  Created by Leo Thomas on 20.10.17.
//  Copyright © 2017 Leo Thomas. All rights reserved.
//

import Foundation
#if os(iOS) || os(tvOS)
    import UIKit
#endif

class FrameRateManager {

    static let shared = FrameRateManager()
    static let frameRateChangedNotificationName = NSNotification.Name("FrameRateChangedNotification")

    init() {
        customFrameRate = Settings.customFrameRate
        #if os(iOS) || os(tvOS)
            NotificationCenter.default.addObserver(self, selector: #selector(powerModeDidChange), name: .NSProcessInfoPowerStateDidChange, object: nil)
        #endif
        NotificationCenter.default.addObserver(self, selector: #selector(ignoreLowPowerModeDidChange), name: Settings.ignoreLowPowerModeChangedNotificationName, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(customFrameRateChanged), name: Settings.customFrameRateChangedNotificationName, object: nil)
    }

    let lowPowerModeFrameRate: Int = 40
    var customFrameRate: Int? {
        didSet {
            postFrameRateChanged()
        }
    }

    let maxFrameRate: Int = {
        #if os(iOS) || os(tvOS)
            return UIScreen.main.maximumFramesPerSecond
        #else
            return 60
        #endif
    }()

    var isLowPowerModeEnabled: Bool {
        #if os(iOS) || os(tvOS)
            return ProcessInfo.processInfo.isLowPowerModeEnabled
        #else
            return false
        #endif
    }

    var frameRate: Int {
        let unwrappedCustomFrameRate = customFrameRate ?? maxFrameRate
        if isLowPowerModeEnabled && !Settings.ignoreLowPowerMode {
            return min(lowPowerModeFrameRate, unwrappedCustomFrameRate)
        }
        return min(maxFrameRate, unwrappedCustomFrameRate)
    }
    
    var frameInterval: TimeInterval {
        return 1 / Double(frameRate)
    }

    @objc func powerModeDidChange() {
        postFrameRateChanged()
    }

    @objc func customFrameRateChanged() {
        customFrameRate = Settings.customFrameRate
    }

    @objc func ignoreLowPowerModeDidChange() {
        if isLowPowerModeEnabled && Settings.ignoreLowPowerMode {
            postFrameRateChanged()
        }
    }

    func postFrameRateChanged() {
        NotificationCenter.default.post(name: FrameRateManager.frameRateChangedNotificationName, object: frameRate)
    }
}

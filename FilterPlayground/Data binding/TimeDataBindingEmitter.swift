//
//  TimeDataBindingEmitter.swift
//  FilterPlayground
//
//  Created by Leo Thomas on 15.10.17.
//  Copyright © 2017 Leo Thomas. All rights reserved.
//

import Foundation
#if os(iOS) || os(tvOS)
    import UIKit
#endif

class TimeDataBindingEmitter: DataBindingEmitter {

    static let shared: DataBindingEmitter = TimeDataBindingEmitter()

    var timer: Timer?
    var time: TimeInterval = 0

    let interval: TimeInterval = {
        var fps = 60
        // todo move fps to a central place and adjust if low power mode is enabled
        #if os(iOS) || os(tvOS)
            fps = UIScreen.main.maximumFramesPerSecond
        #endif
        return 1 / Double(fps)
    }()

    func activate() {
        guard timer == nil else { return }
        timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true, block: didUpdate)
        time = 0
        timer?.fire()
    }

    func deactivate() {
        timer?.invalidate()
        timer = nil
    }

    func didUpdate(timer _: Timer) {
        time += interval
        DataBindingContext.shared.emit(value: time, for: .time)
    }
}

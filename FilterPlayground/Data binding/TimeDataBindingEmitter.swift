//
//  TimeDataBindingEmitter.swift
//  FilterPlayground
//
//  Created by Leo Thomas on 15.10.17.
//  Copyright © 2017 Leo Thomas. All rights reserved.
//

import Foundation

class TimeDataBindingEmitter: DataBindingEmitter {

    static let shared: DataBindingEmitter = TimeDataBindingEmitter()

    var timer: Timer?
    var time: TimeInterval = 0

    init() {
        NotificationCenter.default.addObserver(self, selector: #selector(frameRateChanged), name: FrameRateManager.frameRateChangedNotificationName, object: nil)
    }

    func activate() {
        guard timer == nil else { return }
        time = 0
        activateTimer()
    }

    func deactivate() {
        deactivateTimer()
    }

    func activateTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: FrameRateManager.shared.frameInterval, repeats: true, block: didUpdate)
        timer?.fire()
    }

    func deactivateTimer() {
        timer?.invalidate()
        timer = nil
    }

    func didUpdate(timer t: Timer) {
        time += t.timeInterval
        DataBindingContext.shared.emit(value: time, for: .time)
    }

    @objc func frameRateChanged() {
        guard timer != nil else { return }
        deactivateTimer()
        activateTimer()
    }
}

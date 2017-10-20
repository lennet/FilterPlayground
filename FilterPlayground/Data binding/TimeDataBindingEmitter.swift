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

    var interval: TimeInterval {
        let fps = FrameRateManager.shared.frameRate
        return 1 / Double(fps)
    }

    func activate() {
        guard timer == nil else { return }
        time = 0
        activateTimer()
    }

    func deactivate() {
        deactivateTimer()
    }
    
    func activateTimer()  {
        timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true, block: didUpdate)
        timer?.fire()
    }
    
    func deactivateTimer() {
        timer?.invalidate()
        timer = nil
    }

    func didUpdate(timer _: Timer) {
        time += interval
        DataBindingContext.shared.emit(value: time, for: .time)
    }
    
    @objc func frameRateChanged() {
        guard timer != nil else { return }
        deactivateTimer()
        activateTimer()
    }
}

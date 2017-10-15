//
//  TouchDataBindingEmitter.swift
//  FilterPlayground
//
//  Created by Leo Thomas on 15.10.17.
//  Copyright © 2017 Leo Thomas. All rights reserved.
//

import Foundation
import CoreGraphics

class TouchDataBindingEmitter: DataBindingEmitter {

    static let shared: DataBindingEmitter = TouchDataBindingEmitter()

    var isActive: Bool = false

    func activate() {
        isActive = true
    }

    func deactivate() {
        isActive = false
    }

    func detectedTouch(point: CGPoint) {
        guard isActive else { return }
        DataBindingContext.shared.emit(value: point, for: .touch)
    }
}

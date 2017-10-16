//
//  OutputContainerView.swift
//  FilterPlayground
//
//  Created by Leo Thomas on 15.10.17.
//  Copyright © 2017 Leo Thomas. All rights reserved.
//

import UIKit

class OutputContainerView: UIView {

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        guard let touch = touches.first else { return }
        detectedTouch(for: touch.location(in: self))
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        guard let touch = touches.first else { return }
        detectedTouch(for: touch.location(in: self))
    }

    func detectedTouch(for location: CGPoint) {
        var relativeLocation = location
        relativeLocation.x = (relativeLocation.x / bounds.width) * 100
        relativeLocation.y = (relativeLocation.y / bounds.height) * 100
        (TouchDataBindingEmitter.shared as! TouchDataBindingEmitter).detectedTouch(point: relativeLocation)
    }
}

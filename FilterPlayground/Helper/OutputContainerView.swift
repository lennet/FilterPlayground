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
        (TouchDataBindingEmitter.shared as! TouchDataBindingEmitter).detectedTouch(point: touch.location(in: self))
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        guard let touch = touches.first else { return }
        (TouchDataBindingEmitter.shared as! TouchDataBindingEmitter).detectedTouch(point: touch.location(in: self))
    }
}

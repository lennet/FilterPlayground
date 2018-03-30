//
//  AllTouchesPanGestureRecognizer.swift
//  FilterPlayground
//
//  Created by Leo Thomas on 30.11.17.
//  Copyright © 2017 Leo Thomas. All rights reserved.
//

import UIKit
import UIKit.UIGestureRecognizerSubclass

// this is neccessary to get a pan directly after the first touch
public class AllTouchesPanGestureRecognizer: UIPanGestureRecognizer {
    public var callBack: ((_ recognizer: AllTouchesPanGestureRecognizer, _ state: UIGestureRecognizerState) -> Void)?

    public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent) {
        super.touchesBegan(touches, with: event)
        state = .began
        callBack?(self, .began)
    }

    public override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent) {
        super.touchesMoved(touches, with: event)
        callBack?(self, .changed)
    }

    public override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent) {
        super.touchesEnded(touches, with: event)
        callBack?(self, .ended)
    }

    public override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent) {
        super.touchesCancelled(touches, with: event)
        callBack?(self, .cancelled)
    }
}

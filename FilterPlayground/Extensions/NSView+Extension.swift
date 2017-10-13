//
//  NSView+Extension.swift
//  FilterPlayground
//
//  Created by Leo Thomas on 13.10.17.
//  Copyright © 2017 Leo Thomas. All rights reserved.
//

import Cocoa

extension NSView {

    func setNeedsDisplay() {
        setNeedsDisplay(bounds)
    }
}

//
//  Vector2ValuePicker.swift
//  FilterPlayground
//
//  Created by Leo Thomas on 29.10.17.
//  Copyright © 2017 Leo Thomas. All rights reserved.
//

import UIKit

class Vector2ValuePicker: VectorValuePicker {

    required convenience init?(frame: CGRect, value: KernelArgumentValue) {
        guard case let KernelArgumentValue.vec2(x, y) = value else { return nil }
        self.init(frame: frame, values: [x, y], value: value)
    }

    override func updatedValues() {
        value = .vec2(values[0], values[1])
        super.updatedValues()
    }
    
    override func values(for kernelArgumentValue: KernelArgumentValue) -> [Float] {
        guard case let KernelArgumentValue.vec2(x, y) = value else { return [] }
        return [x,y]
    }
}

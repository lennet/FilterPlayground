//
//  Vector4ValuePicker.swift
//  FilterPlayground
//
//  Created by Leo Thomas on 29.10.17.
//  Copyright © 2017 Leo Thomas. All rights reserved.
//

import UIKit

class Vector4ValuePicker: VectorValuePicker {

    override var prefferedHeight: Float {
        return 84
    }

    required convenience init?(frame: CGRect, value: KernelArgumentValue) {
        guard case let KernelArgumentValue.vec4(x, y, z, w) = value else { return nil }
        self.init(frame: frame, values: [x, y, z, w], value: value)
    }

    override func updatedValues() {
        value = .vec4(values[0], values[1], values[2], values[3])
        super.updatedValues()
    }

    override func values(for _: KernelArgumentValue) -> [Float] {
        guard case let KernelArgumentValue.vec4(x, y, z, w) = value else { return [] }
        return [x, y, z, w]
    }
}

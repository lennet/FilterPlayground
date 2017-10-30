//
//  Vector3ValuePicker.swift
//  FilterPlayground
//
//  Created by Leo Thomas on 29.10.17.
//  Copyright © 2017 Leo Thomas. All rights reserved.
//

import UIKit

class Vector3ValuePicker: VectorValuePicker {

    required convenience init?(frame: CGRect, value: KernelArgumentValue) {
        guard case let KernelArgumentValue.vec3(x, y, z) = value else { return nil }
        self.init(frame: frame, values: [x, y, z], value: value)
    }

    override func updatedValues() {
        value = .vec3(values[0], values[1], values[2])
        super.updatedValues()
    }
    
    override func values(for kernelArgumentValue: KernelArgumentValue) -> [Float] {
        guard case let KernelArgumentValue.vec3(x, y, z) = value else { return [] }
        return [x,y,z]
    }

}

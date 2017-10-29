//
//  KernelArgumentValueView.swift
//  FilterPlayground
//
//  Created by Leo Thomas on 29.10.17.
//  Copyright © 2017 Leo Thomas. All rights reserved.
//

import UIKit

protocol KernelArgumentValueView: class {
    var updatedValueCallback: ((KernelArgumentValue) -> Void)? { get set }
    var value: KernelArgumentValue { get set }
    init?(frame: CGRect, value: KernelArgumentValue)
}

class KernelArgumentValueViewHelper {

    static func view(for valueType: KernelArgumentType) -> KernelArgumentValueView.Type {
        switch valueType {
        case .float:
            return FloatPickerButton.self
        case .color:
            return ColorPickerButton.self
        case .vec2:
            return Vector2ValuePicker.self
        case .vec3:
            return Vector3ValuePicker.self
        case .vec4:
            return Vector4ValuePicker.self
        case .sample:
            return SampleValuePicker.self
        }
    }
}

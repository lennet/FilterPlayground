//
//  KernelArgumentValueView.swift
//  FilterPlayground
//
//  Created by Leo Thomas on 29.10.17.
//  Copyright © 2017 Leo Thomas. All rights reserved.
//

import UIKit

protocol KernelArgumentValueView: class {
    // 0 for default height
    var prefferedHeight: CGFloat { get }
    var prefferedUIAxis: UILayoutConstraintAxis { get }
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
        case .sample,
             .texture2d:
            return SampleValuePicker.self
        case .uint2:
            return Vector2ValuePicker.self
        case .void:
            fatalError()
        }
    }

    static func type(for view: KernelArgumentValueView) -> KernelArgumentType {
        switch view {
        case is FloatPickerButton:
            return .float
        case is ColorPickerButton:
            return .color
        case is Vector2ValuePicker:
            return .vec2
        case is Vector3ValuePicker:
            return .vec3
        case is Vector4ValuePicker:
            return .vec4
        case is SampleValuePicker:
            return .sample
        default:
            fatalError("missing case for view: \(view.self)")
        }
    }
}

//
//  FloatPickerButton.swift
//  FilterPlayground
//
//  Created by Leo Thomas on 29.10.17.
//  Copyright © 2017 Leo Thomas. All rights reserved.
//

import UIKit

class FloatPickerButton: ValuePickerButton {
    var min: Float?
    var max: Float?

    var inputObject: FloatPickerObject = FloatPickerObject()
    var resetCircularSlider = true

    @objc override func handleTap() {
        let viewController = FloatPickerViewController.instantiate()
        viewController.min = min
        viewController.max = max
        viewController.startValue = value.asKernelValue as! Float
        inputObject.set(value: value.asKernelValue as! Float)
        viewController.valueChanged = { [weak self] value in
            guard let strongSelf = self else { return }
            strongSelf.inputObject = value
            strongSelf.value = .float(Float(value.floatRepresentation))
            strongSelf.updatedValueCallback?(strongSelf.value)
        }

        present(viewController: viewController)
    }

    override func updateButtonAfterValueChanged() {
        if let value = value.asKernelValue as? Float {
            if value != inputObject.floatRepresentation {
                inputObject.set(value: value)
            }
        }
        setTitle(inputObject.stringRepresentation, for: .normal)
        UIView.performWithoutAnimation {
            layoutIfNeeded()
        }
    }
}

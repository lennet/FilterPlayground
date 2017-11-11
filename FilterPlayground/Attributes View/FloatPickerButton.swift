//
//  FloatPickerButton.swift
//  FilterPlayground
//
//  Created by Leo Thomas on 29.10.17.
//  Copyright © 2017 Leo Thomas. All rights reserved.
//

import UIKit

class FloatPickerButton: ValuePickerButton {

    @objc override func handleTap() {
        let viewController = FloatPickerViewController.instantiate()

        viewController.valueChanged = { [weak self] value in
            guard let strongSelf = self else { return }
            strongSelf.value = .float(Float(value))
            strongSelf.updatedValueCallback?(strongSelf.value)
        }

        present(viewController: viewController)
    }

    override func updateButtonAfterValueChanged() {
        guard case let .float(a) = value else {
            return
        }
        setTitle("\(a)", for: .normal)
    }
}

//
//  ColorPickerButton.swift
//  FilterPlayground
//
//  Created by Leo Thomas on 29.10.17.
//  Copyright © 2017 Leo Thomas. All rights reserved.
//

import UIKit

class ColorPickerButton: ValuePickerButton {

    @objc override func handleTap() {
        let viewController = ColorPickerViewController.instantiate()
        viewController.colorChanged = { r, g, b, a in
            self.value = .color(r, g, b, a)
            self.updatedValueCallback?(self.value)
        }
        present(viewController: viewController)
    }

    override func updateButtonAfterValueChanged() {
        guard case let .color(r, g, b, a) = value else {
            return
        }
        backgroundColor = UIColor(displayP3Red: CGFloat(r), green: CGFloat(g), blue: CGFloat(b), alpha: CGFloat(a))
    }
}

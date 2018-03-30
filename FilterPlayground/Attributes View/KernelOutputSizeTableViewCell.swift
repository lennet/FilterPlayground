//
//  KernelOutputSizeTableViewCell.swift
//  FilterPlayground
//
//  Created by Leo Thomas on 12.11.17.
//  Copyright © 2017 Leo Thomas. All rights reserved.
//

import UIKit

class KernelOutputSizeTableViewCell: UITableViewCell {
    @IBOutlet var modeSegmentedControl: UISegmentedControl!
    @IBOutlet var labels: [UILabel]!
    var buttons: [FloatPickerButton] {
        return [
            heightPickerButton,
            widthPickerButton,
            xPickerButton,
            yPickerButton,
        ]
    }

    @IBOutlet var heightPickerButton: FloatPickerButton!
    @IBOutlet var widthPickerButton: FloatPickerButton!
    @IBOutlet var yPickerButton: FloatPickerButton!
    @IBOutlet var xPickerButton: FloatPickerButton!
    @IBOutlet var positionStackView: UIStackView!

    static let identifier = "KernelOutputSizeTableViewCellIdentifier"
    var didUpdatedOutputSize: ((KernelOutputSize) -> Void)?
    var canSetPosition: Bool = true {
        didSet {
            positionStackView.isHidden = !canSetPosition
        }
    }

    var inheritSize: CGRect = .zero {
        didSet {
            configure()
        }
    }

    var outputSize: KernelOutputSize = .inherit {
        didSet {
            configure()
        }
    }

    override func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)
        configureButtons()
        updateColors()
    }

    func configure() {
        switch outputSize {
        case .inherit:
            updateSubViews(enabled: false)
            updateButtons(for: inheritSize)
            break
        case let .custom(value):
            updateSubViews(enabled: true)
            updateButtons(for: value)
            break
        }
    }

    func updateButtons(for rect: CGRect) {
        xPickerButton.value = .float(Float(rect.origin.x))
        yPickerButton.value = .float(Float(rect.origin.y))
        widthPickerButton.value = .float(Float(rect.size.width))
        heightPickerButton.value = .float(Float(rect.size.height))
    }

    @IBAction func modeChanged(_: Any) {
        switch modeSegmentedControl.selectedSegmentIndex {
        case 0:
            outputSize = .inherit
        case 1:
            outputSize = .custom(inheritSize)
        default:
            fatalError()
        }
        didUpdateValues()
    }

    func updateSubViews(enabled: Bool) {
        buttons.forEach { button in
            button.isEnabled = enabled
        }
        labels.forEach { label in
            label.textColor = enabled ? .black : .gray
        }
    }

    func configureButtons() {
        buttons.forEach { button in
            button.updatedValueCallback = { [weak self] _ in
                self?.didUpdateValues()
            }
            button.min = 0
        }
        widthPickerButton.min = 1
        heightPickerButton.min = 1
        heightPickerButton.value = .float(1)
        widthPickerButton.value = .float(1)
    }

    func didUpdateValues() {
        if case .custom = outputSize {
            let x = CGFloat(xPickerButton.value.asKernelValue as! Float)
            let y = CGFloat(yPickerButton.value.asKernelValue as! Float)
            let width = CGFloat(widthPickerButton.value.asKernelValue as! Float)
            let height = CGFloat(heightPickerButton.value.asKernelValue as! Float)
            outputSize = .custom(CGRect(x: x, y: y, width: width, height: height))
        }
        didUpdatedOutputSize?(outputSize)
    }

    func updateColors() {
        buttons.forEach { button in
            button.setTitleColor(.blue, for: .normal)
            button.setTitleColor(.gray, for: .disabled)
        }
    }
}

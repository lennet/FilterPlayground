//
//  KernelOutputSizeTableViewCell.swift
//  FilterPlayground
//
//  Created by Leo Thomas on 12.11.17.
//  Copyright © 2017 Leo Thomas. All rights reserved.
//

import UIKit

class KernelOutputSizeTableViewCell: UITableViewCell {
    @IBOutlet weak var modeSegmentedControl: UISegmentedControl!
    @IBOutlet var labels: [UILabel]!
    var buttons: [FloatPickerButton] {
        return [
            heightPickerButton,
            widthPickerButton,
            xPickerButton,
            yPickerButton,
        ]
    }

    @IBOutlet weak var heightPickerButton: FloatPickerButton!
    @IBOutlet weak var widthPickerButton: FloatPickerButton!
    @IBOutlet weak var yPickerButton: FloatPickerButton!
    @IBOutlet weak var xPickerButton: FloatPickerButton!

    static let identifier = "KernelOutputSizeTableViewCellIdentifier"

    var outputSize: KernelOutputSize? {
        didSet {
            configure()
        }
    }
    
    override func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)
        updateColors()
    }

    func configure() {
        guard let size = outputSize else { return }
        switch size {
        case .inherit:
            updateSubViews(enabled: false)
            break
        case .custom:
            updateSubViews(enabled: true)
            break
        }
    }

    @IBAction func modeChanged(_: Any) {
        switch modeSegmentedControl.selectedSegmentIndex {
        case 0:
            outputSize = .inherit
        case 1:
            // TODO: get size from buttons
            outputSize = .custom(.zero)
        default:
            fatalError()
        }
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
    }

    func didUpdateValues() {
    }

    func updateColors() {
        buttons.forEach { button in
            button.setTitleColor(.blue, for: .normal)
            button.setTitleColor(.gray, for: .disabled)
        }
    }
}

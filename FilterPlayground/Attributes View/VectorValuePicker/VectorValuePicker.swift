//
//  VectorValuePicker.swift
//  FilterPlayground
//
//  Created by Leo Thomas on 16.08.17.
//  Copyright © 2017 Leo Thomas. All rights reserved.
//

import UIKit

class VectorValuePicker: UIControl, KernelArgumentValueView, UIPopoverPresentationControllerDelegate {
    var prefferedHeight: CGFloat {
        return 0
    }

    var prefferedUIAxis: UILayoutConstraintAxis {
        return .horizontal
    }

    var updatedValueCallback: ((KernelArgumentValue) -> Void)?

    var value: KernelArgumentValue {
        didSet {
            values = values(for: value)
        }
    }

    var poppoverControllerPresentationController: UIPopoverPresentationController?
    var floatPicker: FloatPickerViewController?
    var currentHighlightedIndex: Int = 0
    var numberOfValues: Int {
        return values.count
    }

    var values: [Float] {
        didSet {
            updateLabels()
        }
    }

    let stackView: UIStackView = {
        let view = UIStackView()
        view.autoresizingMask = UIViewAutoresizing.flexibleWidth.union(.flexibleHeight)
        view.distribution = .fillEqually
        view.axis = .vertical
        return view
    }()

    required convenience init?(frame: CGRect, value: KernelArgumentValue) {
        guard case let KernelArgumentValue.vec2(x, y) = value else { return nil }
        self.init(frame: frame, values: [x, y], value: value)
    }

    init(frame: CGRect, values: [Float], value: KernelArgumentValue) {
        self.values = values
        self.value = value
        super.init(frame: frame)
        stackView.frame = bounds
        addSubview(stackView)
        (1 ... numberOfValues).forEach(addFloatPicker)

        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        addGestureRecognizer(tapGestureRecognizer)
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func addFloatPicker(index _: Int) {
        let label = UILabel()
        label.frame.size.width = bounds.width
        label.autoresizingMask = .flexibleWidth
        label.textAlignment = .center
        label.text = "0.0"
        stackView.addArrangedSubview(label)
    }

    @objc func handleTap() {
        let viewController = FloatPickerViewController.instantiate()
        viewController.showNextButton = true
        floatPicker = viewController
        viewController.valueChanged = { value in
            self.values[self.currentHighlightedIndex - 1] = value.floatRepresentation
            guard let label = self.stackView.arrangedSubviews[self.currentHighlightedIndex - 1] as? UILabel else {
                return
            }
            label.text = value.stringRepresentation
            self.updatedValues()
        }

        viewController.nextButtonTappedCallback = {
            self.highlight(at: self.currentHighlightedIndex + 1)
        }

        viewController.previousButtonTappedCallback = {
            self.highlight(at: self.currentHighlightedIndex - 1)
        }

        viewController.modalPresentationStyle = .popover
        viewController.popoverPresentationController?.sourceView = self
        viewController.popoverPresentationController?.delegate = self
        poppoverControllerPresentationController = viewController.popoverPresentationController

        UIApplication.shared.keyWindow?.rootViewController?.present(viewController, animated: true, completion: nil)
        highlight(at: 1)
    }

    func updatedValues() {
        updatedValueCallback?(value)
    }

    func values(for _: KernelArgumentValue) -> [Float] {
        fatalError("override this method")
    }

    func updateLabels() {
        for (index, value) in values.enumerated() {
            guard let label = self.stackView.arrangedSubviews[index] as? UILabel else {
                continue
            }
            label.text = "\(value)"
        }
    }

    func highlight(at index: Int) {
        guard currentHighlightedIndex != index else {
            return
        }
        currentHighlightedIndex = index
        stackView.arrangedSubviews.enumerated().forEach { i, view in
            guard let label = view as? UILabel else {
                return
            }
            if index == i + 1 {
                label.textColor = .blue

                // TODO: fix updating sourcerect
                self.poppoverControllerPresentationController?.sourceView = label
                self.poppoverControllerPresentationController?.sourceRect = label.bounds
            } else {
                label.textColor = .black
            }
        }

        floatPicker?.set(value: CGFloat(values[self.currentHighlightedIndex - 1]))
        floatPicker?.showNextButton = currentHighlightedIndex < numberOfValues
        floatPicker?.showPreviousButton = currentHighlightedIndex > 1
    }

    func popoverPresentationControllerDidDismissPopover(_: UIPopoverPresentationController) {
        highlight(at: 1)
    }

    func adaptivePresentationStyle(for _: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
}

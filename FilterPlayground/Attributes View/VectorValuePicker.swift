//
//  VectorValuePicker.swift
//  FilterPlayground
//
//  Created by Leo Thomas on 16.08.17.
//  Copyright © 2017 Leo Thomas. All rights reserved.
//

import UIKit

class VectorValuePicker: UIControl, UIPopoverPresentationControllerDelegate {

    var poppoverControllerPresentationController: UIPopoverPresentationController?
    var floatPicker: FloatPickerViewController?
    var currentHighlightedIndex: Int = 0
    var numberOfValues: Int {
        return values.count
    }

    var valuesChanged: (([Float]) -> Void)?
    var values: [Float]

    let stackView: UIStackView = {
        let view = UIStackView()
        view.autoresizingMask = UIViewAutoresizing.flexibleWidth.union(.flexibleHeight)
        view.distribution = .fillEqually
        view.axis = .vertical
        return view
    }()

    init(frame: CGRect, values: [Float]) {
        self.values = values
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
        let viewController = UIStoryboard(name: "ValuePicker", bundle: nil).instantiateViewController(withIdentifier: "SelectFloatViewControllerIdentifier") as! FloatPickerViewController
        viewController.showNextButton = true
        floatPicker = viewController
        viewController.valueChanged = { value in
            guard let label = self.stackView.arrangedSubviews[self.currentHighlightedIndex - 1] as? UILabel else {
                return
            }
            self.values[self.currentHighlightedIndex - 1] = Float(value)
            label.text = "\(value)"
            self.valuesChanged?(self.values)
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

                // todo fix updating sourcerect
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

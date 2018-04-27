//
//  FloatPickerViewController.swift
//  FilterPlayground
//
//  Created by Leo Thomas on 08.08.17.
//  Copyright © 2017 Leo Thomas. All rights reserved.
//

import UIKit

// TODO: implement consitent highlighted state and improve delete button,

class FloatPickerViewController: UIViewController, Identifiable {
    @IBOutlet var previousButton: FloatSelectionButton!
    @IBOutlet var nextButton: FloatSelectionButton!
    @IBOutlet var slider: CircularSlider!
    @IBOutlet var buttonsView: UIView!
    @IBOutlet var buttonsViewTopConstraint: NSLayoutConstraint!

    var min: Float?
    var max: Float?
    var startValue: Float = 0

    var inputObject = FloatPickerObject(floatLiteral: 0)

    var defaultContentSize: CGSize {
        return CGSize(width: 225, height: 400 + (showNextButton || showPreviousButton ? 75 : 0))
    }

    var showNextButton = false {
        didSet {
            loadViewIfNeeded()
            nextButton.isHidden = !showNextButton
            nextButton.needsLeftBorder = showNextButton && showPreviousButton
            nextButton.superview?.layoutIfNeeded()
            updateContentSize()
        }
    }

    var showPreviousButton = false {
        didSet {
            loadViewIfNeeded()
            nextButton.needsLeftBorder = showNextButton && showPreviousButton
            previousButton.isHidden = !showPreviousButton
            previousButton.setNeedsDisplay()
            nextButton.superview?.layoutIfNeeded()
            updateContentSize()
        }
    }

    var valueChanged: ((FloatPickerObject) -> Void)?
    var nextButtonTappedCallback: (() -> Void)?
    var previousButtonTappedCallback: (() -> Void)?

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        slider.addTarget(self, action: #selector(sliderDidBeginEditing), for: .editingDidBegin)
        slider.addTarget(self, action: #selector(sliderDidEndEditing), for: .editingDidEnd)
        slider.value = CGFloat(startValue)
        updateContentSize()
    }

    @objc func sliderDidBeginEditing() {
        buttonsViewTopConstraint.constant = view.frame.height
        UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseInOut, animations: {
            self.view.layoutIfNeeded()
            self.buttonsView.alpha = 0
            self.preferredContentSize = CGSize(width: self.preferredContentSize.width, height: self.slider.bounds.height + 2 * self.slider.frame.origin.y)
        }) { _ in
            self.buttonsView.isHidden = true
        }
    }

    @objc func sliderDidEndEditing() {
        buttonsView.isHidden = false
        buttonsViewTopConstraint.constant = 80
        UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseInOut, animations: {
            self.view.layoutIfNeeded()
            self.buttonsView.alpha = 1
            self.preferredContentSize = self.defaultContentSize
        }, completion: nil)
    }

    @IBAction func sliderValueChanged(_: Any) {
        inputObject.set(value: Float(slider.value))
        update(value: Float(slider.value))
    }

    // Mark: Buttons

    @IBAction func zeroButtonTapped(_: Any) {
        append(number: 0)
    }

    @IBAction func oneButtonTapped(_: Any) {
        append(number: 1)
    }

    @IBAction func twoButtonTapped(_: Any) {
        append(number: 2)
    }

    @IBAction func threeButtonTapped(_: Any) {
        append(number: 3)
    }

    @IBAction func fourButtonTapped(_: Any) {
        append(number: 4)
    }

    @IBAction func fiveButtonTapped(_: Any) {
        append(number: 5)
    }

    @IBAction func sixButtonTapped(_: Any) {
        append(number: 6)
    }

    @IBAction func sevenButtonTapped(_: Any) {
        append(number: 7)
    }

    @IBAction func eightButtonTapped(_: Any) {
        append(number: 8)
    }

    @IBAction func nineButtonTapped(_: Any) {
        append(number: 9)
    }

    @IBAction func dotButtonValueChanged(_ sender: PanButton) {
        if sender.selectedIndex == 0 {
            inputObject.add(input: .dot)
            update(value: inputObject.floatRepresentation)
            slider.roundedSteps = inputObject.containsDot
        } else {
            inputObject.toggleSign()
            slider.value = CGFloat(inputObject.floatRepresentation)
        }
        valueChanged?(inputObject)
    }

    @IBAction func deleteButtonTapped(_: Any) {
        inputObject.removeLastInput()
        update(value: inputObject.floatRepresentation)
        slider.roundedSteps = inputObject.containsDot
    }

    @IBAction func nextButtonTapped(_: Any) {
        nextButtonTappedCallback?()
    }

    @IBAction func previousButtonTapped(_: Any) {
        previousButtonTappedCallback?()
    }

    func updateContentSize() {
        preferredContentSize = defaultContentSize
    }

    func append(number: Int) {
        inputObject.add(input: .digit(number))
        update(value: inputObject.floatRepresentation)
    }

    func update(value: Float) {
        let roundedValue = round(value * 10000) / 10000
        var newValue = roundedValue
        if let minValue = min {
            newValue = Swift.max(newValue, minValue)
        }
        if let maxValue = max {
            newValue = Swift.min(newValue, maxValue)
        }
        valueChanged?(inputObject)
        slider.value = CGFloat(newValue)
    }

    func set(value: CGFloat) {
        slider.value = value
    }
}

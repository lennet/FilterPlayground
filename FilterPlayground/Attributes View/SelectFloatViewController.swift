//
//  SelectFloatViewController.swift
//  FilterPlayground
//
//  Created by Leo Thomas on 08.08.17.
//  Copyright © 2017 Leo Thomas. All rights reserved.
//

import UIKit

class SelectFloatViewController: UIViewController {

    @IBOutlet weak var previousButton: FloatSelectionButton!
    @IBOutlet weak var nextButton: FloatSelectionButton!
    @IBOutlet weak var slider: CircularSlider!
    @IBOutlet weak var buttonsView: UIView!
    @IBOutlet weak var buttonsViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var pointsButton: FloatSelectionButton!
    
    // TODO replace string representation with own struct
    var valueBeforeDot: String = ""
    var valueAfterDot: String? = nil
    var dotAlreadyTapped = false
    var defaultContentSize: CGSize {
        return CGSize(width: 300, height: 500 + (showNextButton || showPreviousButton ? 100 : 0) )
    }

    var showNextButton = false {
        didSet {
            loadViewIfNeeded()
//            UIView.performWithoutAnimation {
                nextButton.isHidden = !showNextButton
                nextButton.needsLeftBorder = showNextButton && showPreviousButton
                nextButton.superview?.layoutIfNeeded()
//            }
            updateContentSize()
        }
    }
    
    var showPreviousButton = false {
        didSet {
            loadViewIfNeeded()
//            UIView.performWithoutAnimation {
                nextButton.needsLeftBorder = showNextButton && showPreviousButton
                previousButton.isHidden = !showPreviousButton
                previousButton.setNeedsDisplay()
                nextButton.superview?.layoutIfNeeded()
//            }
            updateContentSize()
        }
    }
    
    
    var valueChanged: ((CGFloat) -> ())?
    var nextButtonTappedCallback: (()->())?
    var previousButtonTappedCallback: (()->())?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        slider.addTarget(self, action: #selector(sliderDidBeginEditing), for: .editingDidBegin)
        slider.addTarget(self, action: #selector(sliderDidEndEditing), for: .editingDidEnd)
        
        updateContentSize()
    }
    
    @objc func sliderDidBeginEditing() {
        buttonsViewTopConstraint.constant = view.frame.height
        UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseInOut, animations: {
            self.view.layoutIfNeeded()
            self.buttonsView.alpha = 0
            self.preferredContentSize = CGSize(width: self.preferredContentSize.width, height: self.slider.bounds.height + 2 * self.slider.frame.origin.y)
        }) { (_) in
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

    @IBAction func sliderValueChanged(_ sender: Any) {
        self.valueBeforeDot = "\(round(slider.value))"
        if dotAlreadyTapped {
            self.valueAfterDot = "\((round(slider.value*100)/100)-round(slider.value))"
        }
        update(value: slider.value)
    }
    
    //Mark: Buttons
    
    @IBAction func zeroButtonTapped(_ sender: Any) {
        append(number: 0)
    }
    
    @IBAction func oneButtonTapped(_ sender: Any) {
        append(number: 1)
    }

    @IBAction func twoButtonTapped(_ sender: Any) {
        append(number: 2)
    }
    
    @IBAction func threeButtonTapped(_ sender: Any) {
        append(number: 3)
    }
    
    @IBAction func fourButtonTapped(_ sender: Any) {
        append(number: 4)
    }
    
    @IBAction func fiveButtonTapped(_ sender: Any) {
        append(number: 5)
    }
    
    @IBAction func sixButtonTapped(_ sender: Any) {
        append(number: 6)
    }
    
    @IBAction func sevenButtonTapped(_ sender: Any) {
        append(number: 7)
    }
    
    @IBAction func eightButtonTapped(_ sender: Any) {
        append(number: 8)
    }
    
    @IBAction func nineButtonTapped(_ sender: Any) {
        append(number: 9)
    }
    
    @IBAction func dotButtonTapped(_ sender: Any) {
        dotAlreadyTapped = true
        slider.roundedSteps = false
    }
    
    @IBAction func deleteButtonTapped(_ sender: Any) {
        if valueAfterDot != nil && !(valueAfterDot?.isEmpty ?? true) {
            valueAfterDot?.removeLast()
            if valueAfterDot?.isEmpty ?? true {
                dotAlreadyTapped = false
                update(value: CGFloat(Float("\(valueBeforeDot)")!))
            } else {
                update(value: CGFloat(Float("\(valueBeforeDot).\(valueAfterDot!)")!))
            }
        } else if !valueBeforeDot.isEmpty {
            valueBeforeDot.removeLast()
            if valueBeforeDot.isEmpty {
                update(value: 0)
            } else {
                update(value: CGFloat(Float("\(valueBeforeDot)")!))
            }
        }
    }
    
    @IBAction func nextButtonTapped(_ sender: Any) {
        nextButtonTappedCallback?()
    }
    
    @IBAction func previousButtonTapped(_ sender: Any) {
        previousButtonTappedCallback?()
    }
    
    func updateContentSize() {
        self.preferredContentSize = defaultContentSize
    }
    
    func append(number: Int) {
        if dotAlreadyTapped {
            if valueAfterDot == nil {
                valueAfterDot = ""
            }
            valueAfterDot?.append("\(number)")
            update(value: CGFloat(Float("\(valueBeforeDot).\(valueAfterDot!)")!))
        } else {
            valueBeforeDot.append("\(number)")
            update(value: CGFloat(Float("\(valueBeforeDot)")!))
        }
    }
    
    func update(value: CGFloat) {
        let roundedValue = round(value*10000)/10000
        valueChanged?(roundedValue)
        slider.value = roundedValue
    }
    
    func set(value: CGFloat) {
        slider.value = value
    }

 
}

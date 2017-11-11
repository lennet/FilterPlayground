//
//  ColorPickerViewController.swift
//  FilterPlayground
//
//  Created by Leo Thomas on 10.08.17.
//  Copyright © 2017 Leo Thomas. All rights reserved.
//

import UIKit

class ColorPickerViewController: UIViewController {

    class func instantiate() -> ColorPickerViewController {
        return UIStoryboard.valuePicker.instantiateViewController(withIdentifier: "ColorPickerViewControllerIdentifier") as! ColorPickerViewController
    }

    @IBOutlet weak var redSlider: UISlider!
    @IBOutlet weak var blueSlider: UISlider!
    @IBOutlet weak var greenSlider: UISlider!
    @IBOutlet weak var alphaSlider: UISlider!

    @IBOutlet weak var redSliderValueLabel: UILabel!
    @IBOutlet weak var greenSliderValueLabel: UILabel!
    @IBOutlet weak var blueSliderValueLabel: UILabel!
    @IBOutlet weak var alphaSliderValueLabel: UILabel!

    var colorChanged: ((Float, Float, Float, Float) -> Void)?

    @IBAction func sliderValueChanged(_: Any) {
        colorChanged?(round((redSlider.value / 255) * 100) / 100, round((greenSlider.value / 255) * 100) / 100, round((blueSlider.value / 255) * 100) / 100, round((alphaSlider.value) * 100) / 100)

        redSliderValueLabel.text = "\(round(redSlider.value * 10) / 10)"
        greenSliderValueLabel.text = "\(round(greenSlider.value * 10) / 10)"
        blueSliderValueLabel.text = "\(round(blueSlider.value * 10) / 10)"
        alphaSliderValueLabel.text = "\(round(alphaSlider.value * 10) / 10)"
    }
}

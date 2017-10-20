//
//  SettingsTableViewController.swift
//  FilterPlayground
//
//  Created by Leo Thomas on 09.08.17.
//  Copyright © 2017 Leo Thomas. All rights reserved.
//

import UIKit

class SettingsTableViewController: UITableViewController {

    @IBOutlet weak var tabsVsSpacesSegmentedControl: UISegmentedControl!
    @IBOutlet weak var nightModeSwitch: UISwitch!
    @IBOutlet weak var frameRateLabel: UILabel!
    @IBOutlet weak var frameRateSlider: UISlider!
    @IBOutlet weak var ignoreLowPowerModeSwitch: UISwitch!

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        nightModeSwitch.isOn = ThemeManager.shared.currentTheme == NightTheme.self
        tabsVsSpacesSegmentedControl.selectedSegmentIndex = Settings.tabsEnabled ? 0 : 1
        ignoreLowPowerModeSwitch.isOn = Settings.ignoreLowPowerMode
        frameRateSlider.maximumValue = Float(FrameRateManager.shared.maxFrameRate)
        // todo disabled framerateslider in low power mode and with ignorelowpoweermode false
        updateFrameRateLabel()
    }

    @IBAction func nightModeSwitchValueChanged(_: Any) {
        if nightModeSwitch.isOn {
            ThemeManager.shared.currentTheme = NightTheme.self
        } else {
            ThemeManager.shared.currentTheme = Default.self
        }
    }

    @IBAction func ignoresLowPowerModeSwitchValueChanged(_: Any) {
        Settings.ignoreLowPowerMode = ignoreLowPowerModeSwitch.isOn
    }

    @IBAction func tabsVsSpacesValueChanged(_: Any) {
        if tabsVsSpacesSegmentedControl.selectedSegmentIndex == 0 {
            Settings.tabsEnabled = true
        } else if tabsVsSpacesSegmentedControl.selectedSegmentIndex == 1 {
            Settings.tabsEnabled = false
        }
    }

    @IBAction func frameRateValueChanged(_: Any) {
        let newFrameRate = Int(frameRateSlider.value)
        Settings.customFrameRate = newFrameRate
        updateFrameRateLabel()
    }

    func updateFrameRateLabel() {
        frameRateLabel.text = "framerate: \(newFrameRate)"
    }
}

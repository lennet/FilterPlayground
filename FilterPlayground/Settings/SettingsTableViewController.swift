//
//  SettingsTableViewController.swift
//  FilterPlayground
//
//  Created by Leo Thomas on 09.08.17.
//  Copyright © 2017 Leo Thomas. All rights reserved.
//

import UIKit

class SettingsTableViewController: UITableViewController {

    @IBOutlet var tabsVsSpacesSegmentedControl: UISegmentedControl!
    @IBOutlet var nightModeSwitch: UISwitch!
    @IBOutlet var frameRateLabel: UILabel!
    @IBOutlet var frameRateSlider: UISlider!
    @IBOutlet var ignoreLowPowerModeSwitch: UISwitch!
    @IBOutlet var showStatisticsSwitch: UISwitch!

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        nightModeSwitch.isOn = ThemeManager.shared.currentTheme == NightTheme.self
        tabsVsSpacesSegmentedControl.selectedSegmentIndex = Settings.tabsEnabled ? 0 : 1
        ignoreLowPowerModeSwitch.isOn = Settings.ignoreLowPowerMode
        frameRateSlider.maximumValue = Float(FrameRateManager.shared.maxFrameRate)
        frameRateSlider.value = Float(Settings.customFrameRate ?? Int(frameRateSlider.maximumValue))
        showStatisticsSwitch.isOn = Settings.showStatistics
        // TODO: disabled framerateslider in low power mode and with ignorelowpoweermode false
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
        updateFrameRateLabel(frameRate: newFrameRate)
    }

    @IBAction func statisticsSwitchValueChanged(_: Any) {
        Settings.showStatistics = showStatisticsSwitch.isOn
    }

    func updateFrameRateLabel(frameRate: Int = FrameRateManager.shared.frameRate) {
        frameRateLabel.text = "framerate: \(frameRate)"
    }
}

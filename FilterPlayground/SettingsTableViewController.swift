//
//  SettingsTableViewController.swift
//  FilterPlayground
//
//  Created by Leo Thomas on 09.08.17.
//  Copyright © 2017 Leo Thomas. All rights reserved.
//

import UIKit

struct Settings {
    
    static var tabsEnabled: Bool {
        get {
            return UserDefaults.standard.bool(forKey: #function)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: #function)     
        }
    }
    
}

class SettingsTableViewController: UITableViewController {

    @IBOutlet weak var tabsVsSpacesSegmentedControl: UISegmentedControl!
    @IBOutlet weak var nightModeSwitch: UISwitch!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        nightModeSwitch.isOn = ThemeManager.shared.currentTheme == NightTheme.self
        tabsVsSpacesSegmentedControl.selectedSegmentIndex = Settings.tabsEnabled ? 0 : 1
    }
    
    @IBAction func nightModeSwitchValueChanged(_ sender: Any) {
        if nightModeSwitch.isOn {
            ThemeManager.shared.currentTheme = NightTheme.self
        } else {
            ThemeManager.shared.currentTheme = Default.self
        }
    }
    
    @IBAction func tabsVsSpacesValueChanged(_ sender: Any) {
        
        if tabsVsSpacesSegmentedControl.selectedSegmentIndex == 0 {
            Settings.tabsEnabled = true
        } else if tabsVsSpacesSegmentedControl.selectedSegmentIndex == 1 {
            Settings.tabsEnabled = false
        }
    }
}

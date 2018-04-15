//
//  LiveViewController.swift
//  FilterPlayground
//
//  Created by Leo Thomas on 07.08.17.
//  Copyright © 2017 Leo Thomas. All rights reserved.
//

import UIKit

class LiveViewController: UIViewController, Identifiable {
    override func viewDidLoad() {
        super.viewDidLoad()

        NotificationCenter.default.addObserver(self, selector: #selector(themeChanged(notification:)), name: ThemeManager.themeChangedNotificationName, object: nil)
        themeChanged(notification: nil)
    }

    func setup(with kernel: Kernel) {
        view.removeAllSubViews()
        let kernelView = kernel.outputView
        kernelView.frame = view.bounds
        kernelView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(kernelView)
        themeChanged(notification: nil)
    }

    @objc func themeChanged(notification _: Notification?) {
        view.backgroundColor = ThemeManager.shared.currentTheme.liveViewBackground
    }
}

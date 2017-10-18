//
//  LiveViewController.swift
//  FilterPlayground
//
//  Created by Leo Thomas on 07.08.17.
//  Copyright © 2017 Leo Thomas. All rights reserved.
//

import UIKit

class LiveViewController: UIViewController {

    @IBOutlet weak var outputContainerView: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()

        NotificationCenter.default.addObserver(self, selector: #selector(themeChanged(notification:)), name: ThemeManager.themeChangedNotificationName, object: nil)
        themeChanged(notification: nil)
    }

    func setup(with kernel: Kernel) {
        outputContainerView.removeAllSubViews()
        let view = kernel.outputView
        view.frame = outputContainerView.bounds
        view.autoresizingMask = UIViewAutoresizing.flexibleWidth.union(.flexibleHeight)
        outputContainerView.addSubview(view)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }

    @objc func themeChanged(notification _: Notification?) {
        view.backgroundColor = ThemeManager.shared.currentTheme.liveViewBackground
        outputContainerView.backgroundColor = ThemeManager.shared.currentTheme.imageViewBackground
    }
}

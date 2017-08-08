//
//  LiveViewController.swift
//  FilterPlayground
//
//  Created by Leo Thomas on 07.08.17.
//  Copyright © 2017 Leo Thomas. All rights reserved.
//

import UIKit

class LiveViewController: UIViewController {

    @IBOutlet weak var imageView: SelectImageView!
    @IBOutlet weak var inputImageView: SelectImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        NotificationCenter.default.addObserver(self, selector: #selector(themeChanged(notification:)), name: ThemeManager.themeChangedNotificationName, object: nil)
        themeChanged(notification: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func themeChanged(notification: Notification?) {
        self.view.backgroundColor = ThemeManager.shared.currentTheme.liveViewBackground
    }

}

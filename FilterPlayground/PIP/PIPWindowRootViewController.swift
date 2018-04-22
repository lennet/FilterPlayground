//
//  PIPWindowRootViewController.swift
//  FilterPlayground
//
//  Created by Leo Thomas on 22.04.18.
//  Copyright © 2018 Leo Thomas. All rights reserved.
//

import UIKit

class PIPWindowRootViewController: UIViewController {
    var window: PIPWindow
    init(window: PIPWindow) {
        self.window = window
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        window.snapToClosestCorner(with: nil)
    }
}

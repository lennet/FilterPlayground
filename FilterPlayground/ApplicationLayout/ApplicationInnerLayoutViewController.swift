//
//  ApplicationInnerLayoutViewController.swift
//  FilterPlayground
//
//  Created by Leo Thomas on 10.04.18.
//  Copyright © 2018 Leo Thomas. All rights reserved.
//

import UIKit

class ApplicationInnerLayoutViewController: UIViewController {
    let stackView = UIStackView(frame: .zero)

    override func viewDidLoad() {
        super.viewDidLoad()
        stackView.frame = view.bounds
        //        stackView.axis = .vertical
        stackView.distribution = .fillEqually
        stackView.autoresizingMask = [.flexibleHeight, .flexibleWidth]

        view.addSubview(stackView)
    }
}

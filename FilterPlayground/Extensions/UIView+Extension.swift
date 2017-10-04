//
//  UIView+Extension.swift
//  FilterPlayground
//
//  Created by Leo Thomas on 01.10.17.
//  Copyright © 2017 Leo Thomas. All rights reserved.
//

import UIKit

extension UIView {

    func removeAllSubViews() {
        subviews.forEach { view in
            view.removeFromSuperview()
        }
    }
}

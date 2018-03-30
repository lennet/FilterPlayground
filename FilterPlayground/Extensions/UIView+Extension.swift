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

    func constraint(for attribute: NSLayoutAttribute) -> NSLayoutConstraint? {
        for constraint in constraints where constraint.firstAttribute == attribute {
            return constraint
        }
        return nil
    }

    func deactivateConstraints() {
        for constraint in constraints {
            removeConstraint(constraint)
        }
    }
}

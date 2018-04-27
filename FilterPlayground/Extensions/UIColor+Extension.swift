//
//  UIColor+Extension.swift
//  FilterPlayground
//
//  Created by Leo Thomas on 26.04.18.
//  Copyright © 2018 Leo Thomas. All rights reserved.
//

import UIKit

extension UIColor {
    static var randomColor: UIColor {
        return UIColor(red: CGFloat(drand48()), green: CGFloat(drand48()), blue: CGFloat(drand48()), alpha: 1.0)
    }
}

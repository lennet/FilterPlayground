//
//  CGPoint+Extension.swift
//  FilterPlayground
//
//  Created by Leo Thomas on 17.04.18.
//  Copyright © 2018 Leo Thomas. All rights reserved.
//

import CoreGraphics

extension CGPoint {
    func squaredDistance(to point: CGPoint) -> CGFloat {
        return pow(x - point.x, 2) + pow(y - point.y, 2)
    }

    func distance(to point: CGPoint) -> CGFloat {
        return sqrt(squaredDistance(to: point))
    }
}

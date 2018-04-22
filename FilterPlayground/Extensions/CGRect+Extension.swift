//
//  CGRect+Extension.swift
//  FilterPlayground
//
//  Created by Leo Thomas on 17.04.18.
//  Copyright © 2018 Leo Thomas. All rights reserved.
//

import CoreGraphics

extension CGRect {
    var corners: (topLeft: CGPoint, topRight: CGPoint, bottomLeft: CGPoint, bottomRight: CGPoint) {
        return (.zero, CGPoint(x: width, y: 0), CGPoint(x: 0, y: height), CGPoint(x: width, y: height))
    }

    var allCorners: [CGPoint] {
        let tmp = corners
        return [tmp.topLeft, tmp.topRight, tmp.bottomLeft, tmp.bottomRight]
    }
}

//
//  FloatSelectionButton.swift
//  FilterPlayground
//
//  Created by Leo Thomas on 08.08.17.
//  Copyright © 2017 Leo Thomas. All rights reserved.
//

import UIKit

@IBDesignable
class FloatSelectionButton: UIButton {
    @IBInspectable var needsLeftBorder = false {
        didSet {
            setNeedsDisplay()
        }
    }

    @IBInspectable var needsRightBorder = false {
        didSet {
            setNeedsDisplay()
        }
    }

    override func draw(_ rect: CGRect) {
        super.draw(rect)
        let upperBorder = UIBezierPath()
        upperBorder.move(to: .zero)
        upperBorder.addLine(to: CGPoint(x: rect.width, y: 0))
        upperBorder.stroke()

        if needsLeftBorder {
            let leftBorder = UIBezierPath()
            leftBorder.move(to: .zero)
            leftBorder.addLine(to: CGPoint(x: 0, y: rect.height))
            leftBorder.stroke()
        }

        if needsRightBorder {
            let rightBorder = UIBezierPath()
            rightBorder.move(to: CGPoint(x: rect.width, y: 0))
            rightBorder.addLine(to: CGPoint(x: rect.width, y: rect.height))
            rightBorder.stroke()
        }
    }
}

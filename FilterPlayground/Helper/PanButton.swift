//
//  PanButton.swift
//  FilterPlayground
//
//  Created by Leo Thomas on 22.04.18.
//  Copyright © 2018 Leo Thomas. All rights reserved.
//

import UIKit

@IBDesignable
class PanButton: UIControl {
    var selectedIndex = 0

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

    @IBInspectable var firstText = "first" {
        didSet {
            firstLabel.text = firstText
        }
    }

    @IBInspectable var secondText = "second" {
        didSet {
            secondLabel.text = secondText
        }
    }

    override var isHighlighted: Bool {
        didSet {
            if isHighlighted {
                backgroundColor = .lightGray
            } else {
                backgroundColor = .white
            }
        }
    }

    var firstLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.textAlignment = .center
        label.text = "first"
        label.textColor = .blue
        return label
    }()

    var secondLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.textAlignment = .center
        label.text = "hello"
        label.textColor = .blue
        return label
    }()

    override func awakeFromNib() {
        setup()
    }

    override func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)

        setup()
    }

    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        setup()
    }

    func setup() {
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePan(gestureRecognizer:)))
        addGestureRecognizer(panGestureRecognizer)
        addSubview(firstLabel)
        addSubview(secondLabel)
    }

    var offSet: CGFloat = 0 {
        didSet {
            setNeedsLayout()
        }
    }

    @objc func handlePan(gestureRecognizer: UIPanGestureRecognizer) {
        switch gestureRecognizer.state {
        case .changed:
            let translation = gestureRecognizer.translation(in: self)
            offSet += translation.y
            offSet = max(0, offSet)
            offSet = min(offSet, bounds.height / 4)
            break
        case .ended:
            sendValueChangedAction()
            offSet = 0
            break
        default:
            offSet = 0
        }
        gestureRecognizer.setTranslation(.zero, in: self)
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        sendValueChangedAction()
    }

    func sendValueChangedAction() {
        if offSet == bounds.height / 4 {
            selectedIndex = 1
        } else {
            selectedIndex = 0
        }
        sendActions(for: .valueChanged)
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        let ratio = 1 - (offSet / (bounds.height / 4))

        firstLabel.font = UIFont.systemFont(ofSize: 17 + (1 - ratio) * 10)
        firstLabel.sizeToFit()
        firstLabel.frame.size.width = bounds.width
        firstLabel.frame.origin.y = min(bounds.height / 4 + offSet, bounds.height / 2) - firstLabel.frame.size.height / 2

        secondLabel.sizeToFit()
        secondLabel.frame.size.width = bounds.width
        secondLabel.frame.origin.y = 2 * bounds.height / 3 - firstLabel.frame.size.height / 2 + offSet

        secondLabel.alpha = ratio
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

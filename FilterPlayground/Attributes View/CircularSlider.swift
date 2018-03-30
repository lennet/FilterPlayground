//
//  CircularSlider.swift
//  FilterPlayground
//
//  Created by Leo Thomas on 08.08.17.
//  Copyright © 2017 Leo Thomas. All rights reserved.
//

import UIKit

@IBDesignable
class CircularSlider: UIControl, CAAnimationDelegate {
    let lineWidth: CGFloat = 2.0
    var radius: CGFloat {
        return (bounds.width / 2) - lineWidth
    }

    var knob: UIView = {
        let touchSize: CGFloat = 60
        let circleSize: CGFloat = 30
        let view = UIView(frame: CGRect(origin: .zero, size: CGSize(width: touchSize, height: touchSize)))
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = UIBezierPath(arcCenter: CGPoint(x: touchSize / 2, y: touchSize / 2), radius: circleSize / 2, startAngle: 0, endAngle: 2 * CGFloat.pi, clockwise: true).cgPath
        shapeLayer.shadowOffset = CGSize(width: 2, height: 2)
        shapeLayer.shadowRadius = 5
        shapeLayer.shadowOpacity = 0.4
        shapeLayer.fillColor = UIColor.blue.cgColor
        view.layer.addSublayer(shapeLayer)
        return view
    }()

    var previousProgress: CGFloat = 0.5
    var roundedSteps = true
    var value: CGFloat = 0

    override func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)

        addSubview(knob)

        let panGestureRecognier = AllTouchesPanGestureRecognizer()
        panGestureRecognier.callBack = didPanKnob
        knob.addGestureRecognizer(panGestureRecognier)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        knob.center = knobLocation(for: 270)
    }

    @objc func didPanKnob(recognizer: AllTouchesPanGestureRecognizer, state: UIGestureRecognizerState) {
        let location = recognizer.location(in: self)
        recognizer.setTranslation(.zero, in: self)
        let a = angle(for: location)

        knob.center = knobLocation(for: a)

        // TODO: use velocity
        let prog = progress(for: a)
        if previousProgress - prog > 0.70 {
            previousProgress = 0
        } else if prog - previousProgress > 0.70 {
            previousProgress = 1
        }

        if roundedSteps {
            value += round(100 * (prog - previousProgress))
        } else {
            value += round(100 * (prog - previousProgress)) / 100
        }
        sendActions(for: .valueChanged)

        previousProgress = prog

        switch state {
        case .began:
            sendActions(for: .editingDidBegin)
            break
        case .ended,
             .cancelled:
            animateKnobToOrigin(with: a, and: prog)
            sendActions(for: .editingDidEnd)
            break
        default:
            break
        }
    }

    func progress(for angle: CGFloat) -> CGFloat {
        let transformedAngle = angle - 90
        return (transformedAngle + ceil(-transformedAngle / 360) * 360) / 360
    }

    func knobLocation(for angle: CGFloat) -> CGPoint {
        return CGPoint(x: (bounds.width / 2) + radius * cos(angle.asRadian), y: (bounds.height / 2) + radius * sin(angle.asRadian))
    }

    func angle(for location: CGPoint) -> CGFloat {
        return (atan2(location.y - (bounds.height / 2), location.x - (bounds.width / 2)) * 180 / CGFloat.pi + 360).remainder(dividingBy: 360)
    }

    override func draw(_ rect: CGRect) {
        let circleRect = CGRect(origin: CGPoint(x: lineWidth / 2, y: lineWidth / 2), size: CGSize(width: rect.width - lineWidth, height: rect.height - lineWidth))
        let path = UIBezierPath(ovalIn: circleRect)
        path.stroke()
        path.lineWidth = lineWidth
    }

    func animateKnobToOrigin(with angle: CGFloat, and progress: CGFloat) {
        let animation = CAKeyframeAnimation(keyPath: "position")
        animation.fillMode = kCAFillModeForwards
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        animation.duration = 0.25
        animation.isRemovedOnCompletion = false
        let arcCenter = CGPoint(x: bounds.width / 2, y: bounds.height / 2)
        animation.path = UIBezierPath(arcCenter: arcCenter, radius: radius, startAngle: angle.asRadian, endAngle: CGFloat(-90.0).asRadian, clockwise: progress < 0.5).cgPath
        animation.delegate = self
        knob.layer.add(animation, forKey: "Move to Origin")
    }

    func animationDidStop(_: CAAnimation, finished _: Bool) {
        knob.center = knobLocation(for: 270)
        knob.layer.removeAllAnimations()
    }
}

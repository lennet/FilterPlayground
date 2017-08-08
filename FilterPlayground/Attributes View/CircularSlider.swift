//
//  CircularSlider.swift
//  FilterPlayground
//
//  Created by Leo Thomas on 08.08.17.
//  Copyright © 2017 Leo Thomas. All rights reserved.
//

import UIKit

@IBDesignable
class CircularSlider: UIControl {
    
    let lineWidth: CGFloat = 2.0
    var radius: CGFloat {
        return (bounds.width / 2) - lineWidth
    }
    var knob: UIView = {
        let touchSize: CGFloat = 60
        let circleSize: CGFloat = 30
        let view = UIView(frame: CGRect(origin: .zero, size: CGSize(width: touchSize, height: touchSize)))
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = UIBezierPath(arcCenter: CGPoint(x: touchSize/2, y:touchSize/2), radius: circleSize/2, startAngle: 0, endAngle: 2*CGFloat.pi, clockwise: true).cgPath
        shapeLayer.shadowOffset = CGSize(width: 2, height: 2)
        shapeLayer.shadowRadius = 5
        shapeLayer.shadowOpacity = 0.4
        shapeLayer.fillColor = UIColor.blue.cgColor
        view.layer.addSublayer(shapeLayer)
        return view
    }()
    
    var previousProgress: CGFloat = 0
    var roundedSteps = true
    var value: CGFloat = 0
    
    override func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)
        
        addSubview(knob)
        
        let panGestureRecognier = UIPanGestureRecognizer(target: self, action: #selector(didPanKnob(recognizer:)))
        knob.addGestureRecognizer(panGestureRecognier)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        knob.center = knobLocation(for: 270)
    }
    
    @objc func didPanKnob(recognizer: UIPanGestureRecognizer) {
        
        let location = recognizer.location(in: self)
        recognizer.setTranslation(.zero, in: self)
        let a = angle(for: location)

        knob.center = knobLocation(for: a)
        
        // todo use velocity
        let prog = progress(for: a)
        if previousProgress - prog > 0.9 {
            previousProgress = 0
        } else if prog - previousProgress > 0.9 {
            previousProgress = 1
        }
        
        if roundedSteps {
            value += round(100*(prog - previousProgress))
        } else {
            value += round(100*(prog - previousProgress))/100
        }
        sendActions(for: .valueChanged)
        
        previousProgress = prog

        switch recognizer.state {
        case .began:
            sendActions(for: .editingDidBegin)
            break
        case .ended,
             .cancelled:
            // TODO use CAAnimation to animate with custom paths
            UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseInOut, animations: {
                self.knob.center = self.knobLocation(for: 270)
            }, completion: nil)
            sendActions(for: .editingDidEnd)
            break
        default:
            break
        }
        
    }
    
    func progress(for angle: CGFloat) -> CGFloat {
        let progress = (angle+90).remainder(dividingBy: 360) + ((angle+90) < 0 ? 360 : 0)
        if progress < 0 {
            return (abs(progress)) / 360
        } else {
            return progress / 360
        }
    }
    
    func knobLocation(for angle: CGFloat) -> CGPoint {
        return CGPoint(x: (bounds.width/2) + radius * cos(angle.asRadian), y: (bounds.height/2) + radius * sin(angle.asRadian))
    }
    
    func angle(for location: CGPoint) -> CGFloat {
        return (atan2(location.y-(bounds.height/2), location.x-(bounds.width/2)) * 180/CGFloat.pi + 360).remainder(dividingBy: 360)
    }
    
    override func draw(_ rect: CGRect) {
        let circleRect = CGRect(origin: CGPoint(x:lineWidth/2, y:lineWidth/2), size: CGSize(width: rect.width-lineWidth, height: rect.height-lineWidth))
        let path = UIBezierPath(ovalIn: circleRect)
        path.stroke()
        path.lineWidth = lineWidth
    }
    
}

//
//  PIPContainerView.swift
//  FilterPlayground
//
//  Created by Leo Thomas on 15.04.18.
//  Copyright © 2018 Leo Thomas. All rights reserved.
//

import AVFoundation
import UIKit

class PIPContainerView: UIView {
    var timer: Timer?
    var displayLink: CADisplayLink?
    let maxWindowSize = CGSize(width: 100, height: 100)
    let minWindowSize = CGSize(width: 10, height: 10)
    var childViewController: UIViewController?
    lazy var pipWindow: PIPWindow = {
        PIPWindow(containerView: self)
    }()

    private var pressStartDate: Date? {
        didSet {
            if pressStartDate == nil {
                timer?.invalidate()
                displayLink?.invalidate()
                setNeedsLayout()
            } else {
                displayLink = CADisplayLink(target: self, selector: #selector(update))
                displayLink?.add(to: RunLoop.current, forMode: RunLoopMode.defaultRunLoopMode)

                timer = Timer.scheduledTimer(timeInterval: 0.2, target: self, selector: #selector(detachSubView), userInfo: nil, repeats: false)
            }
        }
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        pressStartDate = Date()
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        pipWindow.center = convert(touches.first!.location(in: self), to: window!.screen.coordinateSpace)
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        pipWindow.snapToClosestCorner(with: .zero)
        pressStartDate = nil
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        guard let first = touches.first else {
            return
        }
        pipWindow.snapToClosestCorner(with: first.previousLocation(in: self))
        pressStartDate = nil
    }

    @objc func detachSubView() {
        pressStartDate = nil

        if let subView = subviews.first {
            pipWindow.center = convert(subView.center, to: UIScreen.main.coordinateSpace)

            var size = AVMakeRect(aspectRatio: subView.intrinsicContentSize, insideRect: CGRect(origin: .zero, size: maxWindowSize)).size
            size.width = max(size.width, minWindowSize.width)
            size.height = max(size.height, minWindowSize.height)
            pipWindow.frame.size = size

            subView.removeFromSuperview()
            subView.frame = pipWindow.bounds
            subView.isUserInteractionEnabled = false
            childViewController?.removeFromParentViewController()
            pipWindow.insertSubview(subView, at: 0)
            isHidden = true
            UIViewPropertyAnimator(duration: 0.25, curve: .easeInOut) {
                self.superview?.layoutIfNeeded()
            }.startAnimation()
        }
        pipWindow.makeKeyAndVisible()
    }

    @objc func update() {
        setNeedsLayout()
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        // use touch point as animation center
        for view in subviews {
            if let startDate = pressStartDate {
                let distance: CGFloat = CGFloat(-startDate.timeIntervalSinceNow) * 100
                view.frame = bounds.insetBy(dx: distance, dy: distance)
            } else {
                view.frame = bounds
            }
        }
    }
}

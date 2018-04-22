//
//  PIPWindow.swift
//  FilterPlayground
//
//  Created by Leo Thomas on 15.04.18.
//  Copyright © 2018 Leo Thomas. All rights reserved.
//

import AVFoundation
import UIKit

class PIPWindow: UIWindow {
    private var containerView: PIPContainerView
    var insets: UIEdgeInsets = UIEdgeInsetsMake(84, 20, 20, 20)

    init(containerView: PIPContainerView) {
        self.containerView = containerView
        super.init(frame: .zero)
        rootViewController = PIPWindowRootViewController(window: self)
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    var displayLink: CADisplayLink?

    override func makeKeyAndVisible() {
        super.makeKeyAndVisible()
        displayLink = CADisplayLink(target: self, selector: #selector(update))
        displayLink?.add(to: RunLoop.current, forMode: RunLoopMode.defaultRunLoopMode)
    }

    override func resignKey() {
        super.resignKey()
        displayLink?.invalidate()
    }

    func snapToClosestCorner(with _: CGPoint?, animated: Bool = true) {
        let screenFrame = UIApplication.shared.delegate?.window!!.bounds
        let closestCorner = screenFrame!.allCorners.map { (corner) -> (corner: CGPoint, distance: CGFloat) in
            return (corner: corner, distance: center.squaredDistance(to: corner))
        }.sorted { (lhs, rhs) -> Bool in
            return lhs.distance < rhs.distance
        }

        let corners = screenFrame!.corners
        var tmp = closestCorner.first!.corner

        switch tmp {
        case corners.topLeft:
            tmp.x += frame.size.width / 2 + insets.left
            tmp.y += frame.size.height / 2 + insets.top
            break
        case corners.topRight:
            tmp.x -= frame.size.width / 2 + insets.right
            tmp.y += frame.size.height / 2 + insets.top
            break
        case corners.bottomLeft:
            tmp.x += frame.size.width / 2 + insets.left
            tmp.y -= frame.size.height / 2 + insets.bottom
            break
        case corners.bottomRight:
            tmp.x -= frame.size.width / 2 + insets.right
            tmp.y -= frame.size.height / 2 + insets.bottom
            break
        default:
            break
        }

        UIViewPropertyAnimator(duration: animated ? 0.25 : 0, dampingRatio: 0.9) {
            self.center = tmp
        }.startAnimation()
    }

    /// Snaps to the container if needed :D
    ///
    /// - Returns: A Bool value if the Window snapped to the container
    @discardableResult
    func snapToContainerIfNeed() -> Bool {
        let screenFrame = UIApplication.shared.delegate?.window!!.bounds

        var shouldSnap: Bool
        if traitCollection.userInterfaceIdiom == .pad {
            shouldSnap = frame.maxY > screenFrame!.height
        } else {
            shouldSnap = UIDevice.current.orientation.isLandscape ? frame.maxX > screenFrame!.width : frame.maxY > screenFrame!.height
        }

        if shouldSnap {
            containerView.isHidden = false
            if let first = subviews.first {
                first.removeFromSuperview()
                containerView.addSubview(first)
            }
            UIViewPropertyAnimator(duration: 0.25, dampingRatio: 0.9) {
                self.containerView.superview?.layoutIfNeeded()
            }.startAnimation()

            resignKey()
            removeFromSuperview()
            isHidden = true
            return true
        }
        return false
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        guard let first = touches.first else {
            return
        }
        center = convert(first.location(in: self), to: UIScreen.main.coordinateSpace)
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        guard let first = touches.first else {
            return
        }
        if !snapToContainerIfNeed() {
            snapToClosestCorner(with: first.previousLocation(in: self))
        }
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        if !snapToContainerIfNeed() {
            snapToClosestCorner(with: .zero)
        }
    }

    @objc func update() {
        // TODO: replace with a more generic
        if let size = subviews.first?.subviews.first?.intrinsicContentSize,
            size != .zero {
            let newSize = AVMakeRect(aspectRatio: size, insideRect: CGRect(origin: .zero, size: CGSize(width: 125, height: 125))).size
            if frame.size != newSize {
                frame.size = newSize
                snapToClosestCorner(with: .zero, animated: false)
            }
        }
    }
}

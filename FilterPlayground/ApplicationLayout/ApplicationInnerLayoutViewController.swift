//
//  ApplicationInnerLayoutViewController.swift
//  FilterPlayground
//
//  Created by Leo Thomas on 10.04.18.
//  Copyright © 2018 Leo Thomas. All rights reserved.
//

import UIKit

class ApplicationInnerLayoutViewController: UIViewController, UIGestureRecognizerDelegate {
    let draggingIndicator = DraggingIndicatorView()
    let thirdSize: CGFloat = 200

    var firstSecondRatio: CGFloat = 0.5 {
        didSet {
            view.setNeedsLayout()
        }
    }

    var firstViewController: UIViewController? {
        didSet {
            oldValue?.view.removeFromSuperview()
            oldValue?.removeFromParentViewController()

            guard let first = firstViewController else {
                return
            }
            view.insertSubview(first.view, at: 0)
            addChildViewController(first)
        }
    }

    var secondViewController: UIViewController? {
        didSet {
            oldValue?.view.removeFromSuperview()
            oldValue?.removeFromParentViewController()

            guard let second = secondViewController else {
                return
            }
            view.insertSubview(second.view, at: 0)
            addChildViewController(second)
        }
    }

    var thirdViewController: UIViewController? {
        didSet {
            oldValue?.view.removeFromSuperview()
            oldValue?.removeFromParentViewController()

            guard let third = thirdViewController else {
                return
            }
            view.insertSubview(third.view, at: 0)
            addChildViewController(third)
        }
    }

    var isResizingFirstView = false {
        didSet {
            draggingIndicator.isHidden = !isResizingFirstView
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configureTouchGestureRecognizer()

        draggingIndicator.isHidden = true
        view.addSubview(draggingIndicator)
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        let numberOfViews: CGFloat = CGFloat(childViewControllers.count)
        let realThirdSize = numberOfViews == 3 ? thirdSize : 0
        let maxWidth = (view.frame.width - realThirdSize) / max(numberOfViews - 2, 1)

        let firstFrame = CGRect(origin: CGPoint(x: 0, y: 0), size: CGSize(width: maxWidth * firstSecondRatio, height: view.frame.height))
        firstViewController?.view.frame = firstFrame
        let secondFrame = CGRect(origin: CGPoint(x: firstFrame.size.width, y: 0), size: CGSize(width: maxWidth - firstFrame.width, height: view.frame.height))
        secondViewController?.view.frame = secondFrame
        thirdViewController?.view.frame = CGRect(origin: CGPoint(x: maxWidth, y: 0), size: CGSize(width: realThirdSize, height: view.frame.height))
        draggingIndicator.frame.origin = CGPoint(x: firstFrame.width - draggingIndicator.frame.width / 2, y: view.center.y)
    }

    func configureTouchGestureRecognizer() {
        let gestureRecognizer = AllTouchesPanGestureRecognizer()
        gestureRecognizer.callBack = handleTouch
        gestureRecognizer.delegate = self
        view.addGestureRecognizer(gestureRecognizer)
    }

    func handleTouch(with recognizer: AllTouchesPanGestureRecognizer, state _: UIGestureRecognizerState) {
        guard let first = firstViewController?.view else { return }
        let location = recognizer.location(in: recognizer.view)

        switch recognizer.state {
        case .began:
            isResizingFirstView = abs(location.x.distance(to: first.frame.width)) < 50
            break
        case .changed:
            if isResizingFirstView {
                let translation = recognizer.translation(in: recognizer.view)
                let numberOfViews: CGFloat = CGFloat(childViewControllers.count)
                let maxWidth = (view.frame.width - thirdSize) / max(numberOfViews - 1, 1)

                var newRatio = firstSecondRatio + (translation.x / maxWidth)
                newRatio = max(newRatio, 0)
                newRatio = min(newRatio, 1)
                firstSecondRatio = newRatio

                recognizer.setTranslation(.zero, in: recognizer.view)
            }
            break
        default:
            isResizingFirstView = false
            break
        }
    }

    // MARK: UIGestureRecognizerDelegate

    func gestureRecognizer(_: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith _: UIGestureRecognizer) -> Bool {
        // TODO: Hittest for PIP overlay
        return true
    }
}

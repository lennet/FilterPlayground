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
    var thirdSize: CGFloat = 200

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
        let ratio = numberOfViews > 1 ? firstSecondRatio : 1

        let firstFrame = CGRect(origin: CGPoint(x: 0, y: 0), size: CGSize(width: maxWidth * ratio, height: view.frame.height))
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
        guard let first = firstViewController?.view,
            childViewControllers.count > 1 else { return }
        let location = recognizer.location(in: recognizer.view)

        // TODO: disable textview layout during resizing

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

    var isThirdViewVisible: Bool {
        guard let view = thirdViewController?.view else { return false }
        return view.superview != nil
    }

    func toggleThirdViewControllerVisibility(with viewController: UIViewController) {
        if isThirdViewVisible {
            let originalThirdSize = thirdSize
            view.setNeedsLayout()
            thirdSize = 0
            UIView.animate(withDuration: 0.25, delay: 0, usingSpringWithDamping: 0.9, initialSpringVelocity: 1, options: [], animations: {
                self.view.layoutIfNeeded()
            }) { _ in
                self.thirdViewController = nil
                self.thirdSize = originalThirdSize
            }
        } else {
            thirdViewController = viewController
            UIView.animate(withDuration: 0.25, delay: 0, usingSpringWithDamping: 0.9, initialSpringVelocity: 1, options: [], animations: {
                self.view.layoutIfNeeded()
            }, completion: nil)
        }
    }

    // MARK: UIGestureRecognizerDelegate

    func gestureRecognizer(_: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith _: UIGestureRecognizer) -> Bool {
        return true
    }
}

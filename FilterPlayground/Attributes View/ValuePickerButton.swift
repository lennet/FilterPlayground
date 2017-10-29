//
//  ValuePickerButton.swift
//  FilterPlayground
//
//  Created by Leo Thomas on 29.10.17.
//  Copyright © 2017 Leo Thomas. All rights reserved.
//

import UIKit

class ValuePickerButton: UIButton, KernelArgumentValueView, UIPopoverPresentationControllerDelegate {

    var updatedValueCallback: ((KernelArgumentValue) -> Void)?
    var value: KernelArgumentValue {
        didSet {
            updateButtonAfterValueChanged()
        }
    }

    required init(frame: CGRect, value: KernelArgumentValue) {
        self.value = value
        super.init(frame: frame)
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func present(viewController: UIViewController) {
        guard let presentedViewController = UIApplication.shared.keyWindow?.rootViewController else {
            return
        }
        viewController.modalPresentationStyle = .popover
        viewController.popoverPresentationController?.sourceView = self
        viewController.popoverPresentationController?.sourceRect = bounds
        viewController.popoverPresentationController?.delegate = self

        if let navigationController = presentedViewController as? UINavigationController {
            (navigationController.viewControllers.first as? MainViewController)?.attributesViewController?.view.endEditing(true)
        }

        presentedViewController.present(viewController, animated: true, completion: nil)
    }

    override func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)
        setTitleColor(.black, for: .normal)
        addTarget(self, action: #selector(handleTap), for: .touchUpInside)
        updateButtonAfterValueChanged()
    }

    @objc func handleTap() {
        fatalError("Override this method")
    }

    func updateButtonAfterValueChanged() {
        fatalError("Override this method")
    }

    func adaptivePresentationStyle(for _: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
}

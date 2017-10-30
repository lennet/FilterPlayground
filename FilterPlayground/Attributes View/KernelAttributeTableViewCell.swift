//
//  KernelAttributeTableViewCell.swift
//  FilterPlayground
//
//  Created by Leo Thomas on 29.07.17.
//  Copyright © 2017 Leo Thomas. All rights reserved.
//

import UIKit

class KernelAttributeTableViewCell: UITableViewCell, UIPopoverPresentationControllerDelegate, UITextFieldDelegate {

    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var typeButton: UIButton!
    @IBOutlet weak var valueSelectionContainer: UIView!
    @IBOutlet weak var newArgumentOverlay: UIView!
    @IBOutlet weak var dataBindingButton: UIButton!

    var valueSelectionView: (UIView & KernelArgumentValueView)?

    var valueButton: UIView!
    var selectedBinding: DataBinding = .none {
        didSet {
            guard let attribute = attribute,
                selectedBinding != oldValue else {
                return
            }

            if selectedBinding == .none {
                dataBindingButton.setTitle("Bindings available", for: .normal)
                DataBindingContext.shared.removeObserver(with: attribute.name)
            } else {
                dataBindingButton.setTitle("Remove Binding", for: .normal)
                DataBindingContext.shared.add(observer: self, with: attribute.name)
            }
        }
    }

    var attribute: KernelArgument? {
        didSet {
            nameTextField.text = attribute?.name
            if let type = attribute?.type {
                if let oldType = oldValue?.type,
                    oldType == type {
                    return
                }

                nameTextField.text = attribute?.name
                setupValueView(for: type, value: attribute?.value)
                typeButton.setTitle(type.rawValue, for: .normal)
                dataBindingButton.isHidden = !type.supportsDataBinding
                nameTextField.isEnabled = true
                newArgumentOverlay.isHidden = true
                selectedBinding = attribute?.binding ?? .none
            } else {
                nameTextField.text = nil
                nameTextField.isEnabled = false
                newArgumentOverlay.isHidden = false
                dataBindingButton.isHidden = true
            }
        }
    }

    var updateCallBack: ((UITableViewCell, KernelArgument) -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()
        registerNotifications()
        nameTextField.delegate = self
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        attribute = nil
    }

    @IBAction func nameTextFieldChanged(_: Any) {
        guard let name = nameTextField.text else {
            return
        }
        attribute?.name = name
        update()
    }

    func update() {
        guard let attribute = attribute else {
            return
        }

        updateCallBack?(self, attribute)
    }

    @IBAction func selectType(_ sender: UIButton) {
        presentTypeSelection(with: sender)
    }

    @IBAction func newArgumentButtonTapped(_ sender: UIButton) {
        presentTypeSelection(with: sender)
    }

    @IBAction func dataBindingButtonTapped(_ sender: UIButton) {
        if selectedBinding == .none {
            let viewController = UIStoryboard(name: "ValuePicker", bundle: nil).instantiateViewController(withIdentifier: "selectDataBindingViewControllerIdentifier") as! SelectDataBindingViewController
            viewController.supportedBindings = attribute?.type.availableDataBindings ?? []
            viewController.didSelectBinding = { binding in
                self.attribute?.binding = binding
                self.selectedBinding = binding
            }
            present(viewController: viewController, with: sender)
        } else {
            attribute?.binding = .none
            selectedBinding = .none
        }
    }

    func presentTypeSelection(with sender: UIButton) {
        let viewController = UIStoryboard(name: "ValuePicker", bundle: nil).instantiateViewController(withIdentifier: "selectTypeViewControllerIdentifier") as! SelectTypeViewController
        viewController.didSelectType = { type in
            self.attribute = KernelArgument(name: self.attribute?.name ?? "", type: type, value: type.defaultValue)
            self.update()
            if self.nameTextField.text?.isEmpty ?? true {
                DispatchQueue.main.async {
                    self.nameTextField.becomeFirstResponder()
                }
            }
        }
        present(viewController: viewController, with: sender)
    }

    func setupValueView(for type: KernelArgumentType, value _: KernelArgumentValue?) {
        guard let type = attribute?.type,
            let value = attribute?.value else { return }

        if let valueSelectionView = valueSelectionView,
            KernelArgumentValueViewHelper.type(for: valueSelectionView) == type {
            valueSelectionView.value = value
        } else if let view = KernelArgumentValueViewHelper.view(for: type).init(frame: valueSelectionContainer.bounds, value: value) as? (UIView & KernelArgumentValueView) {
            valueSelectionView?.removeFromSuperview()
            valueSelectionContainer.addSubview(view)
            valueSelectionView?.updatedValueCallback = valueChanged
            valueSelectionView = view
        }
    }

    func valueChanged(value: KernelArgumentValue) {
        attribute?.value = value
        updateCallBack?(self, attribute!)
    }

    func adaptivePresentationStyle(for _: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }

    func registerNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(themeChanged(notification:)), name: ThemeManager.themeChangedNotificationName, object: nil)
        themeChanged(notification: nil)
    }

    @objc func themeChanged(notification _: Notification?) {
        contentView.backgroundColor = ThemeManager.shared.currentTheme.attributesCellBackground
    }

    func present(viewController: UIViewController, with sender: UIView) {
        guard let presentedViewController = UIApplication.shared.keyWindow?.rootViewController else {
            return
        }
        viewController.modalPresentationStyle = .popover
        viewController.popoverPresentationController?.sourceView = sender
        viewController.popoverPresentationController?.sourceRect = sender.bounds
        viewController.popoverPresentationController?.delegate = self

        // dismiss keyboard if needed
        if let navigationController = presentedViewController as? UINavigationController {
            (navigationController.viewControllers.first as? MainViewController)?.attributesViewController?.view.endEditing(true)
        }

        presentedViewController.present(viewController, animated: true, completion: nil)
    }

    // MARK: UITextFieldDelegate

    func textFieldDidEndEditing(_ textField: UITextField) {
        guard let type = self.attribute?.type else { return }
        if textField.text?.isEmpty ?? true {
            let newName = "untitled\(String(describing: type).capitalized)"
            attribute?.name = newName
            textField.text = newName
            update()
        }
    }

    func textFieldShouldEndEditing(_: UITextField) -> Bool {
        return true
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

// TODO: move observer out of this cell because not every attribtue must have a own cell
extension KernelAttributeTableViewCell: DataBindingObserver {

    var observedBinding: DataBinding {
        return selectedBinding
    }

    func valueChanged(value: Any) {
        guard let type = attribute?.type else { return }

        var newValue: KernelArgumentValue?
        switch (type, observedBinding) {
        case (.float, .time):
            if let time = value as? TimeInterval {
                newValue = .float(Float(time))
            }
            break
        case (.sample, .camera):
            if let image = value as? CIImage {
                newValue = .sample(image)
            }
            break
        case (.vec2, .touch):
            if let point = value as? CGPoint {
                newValue = .vec2(Float(point.x), Float(point.y))
            }
            break
        default:
            break
        }
        if let newValue = newValue {
            attribute?.value = newValue
            valueSelectionView?.value = newValue
            update()
        }
    }
}

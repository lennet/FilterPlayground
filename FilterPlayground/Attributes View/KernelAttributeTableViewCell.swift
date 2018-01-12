//
//  KernelAttributeTableViewCell.swift
//  FilterPlayground
//
//  Created by Leo Thomas on 29.07.17.
//  Copyright © 2017 Leo Thomas. All rights reserved.
//

import UIKit

class KernelAttributeTableViewCell: UITableViewCell, UITextFieldDelegate {

    @IBOutlet var valueSelectionHeight: NSLayoutConstraint!
    @IBOutlet var stackView: UIStackView!
    @IBOutlet var nameTextField: UITextField!
    @IBOutlet var typeButton: UIButton!
    @IBOutlet var valueSelectionContainer: UIView!
    @IBOutlet var newArgumentOverlay: UIView!
    @IBOutlet var dataBindingButton: UIButton!

    var supportedTypes: [KernelArgumentType] = []
    weak var valueSelectionView: (UIView & KernelArgumentValueView)?
    var selectedBinding: DataBinding = .none {
        didSet {
            guard selectedBinding != oldValue else {
                return
            }

            updateBindingsButton()
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
        updateBindingsButton()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        attribute = nil
    }

    func updateBindingsButton() {
        if selectedBinding == .none {
            dataBindingButton.setTitle("Bindings available", for: .normal)
        } else {
            dataBindingButton.setTitle("Remove Binding", for: .normal)
        }
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
            let viewController = SelectObjectController(title: "Data Binding", objects: [attribute?.type.availableDataBindings ?? []], callback: { binding, _ in
                self.attribute?.binding = binding as? DataBinding
                self.selectedBinding = binding as! DataBinding
                self.update()
            })
            present(viewController: viewController, with: sender)
        } else {
            attribute?.binding = .none
            selectedBinding = .none
            update()
        }
    }

    func presentTypeSelection(with sender: UIButton) {
        let viewController = SelectObjectController(title: "Type", objects: [supportedTypes]) { [weak self] type, _ in
            let argumentType = type as! KernelArgumentType
            self?.attribute = KernelArgument(index: self?.attribute?.index ?? 0, name: self?.attribute?.name ?? "", type: argumentType, value: argumentType.defaultValue)
            self?.update()
            if self?.nameTextField.text?.isEmpty ?? true {
                DispatchQueue.main.async {
                    self?.nameTextField.becomeFirstResponder()
                }
            }
        }
        viewController.navigationItem.title = "Type"
        present(viewController: viewController, with: sender)
    }

    func setupValueView(for type: KernelArgumentType, value _: KernelArgumentValue?) {
        guard let type = attribute?.type,
            let value = attribute?.value else { return }

        if let valueSelectionView = valueSelectionView,
            KernelArgumentValueViewHelper.type(for: valueSelectionView) == type {
            valueSelectionView.value = value

        } else if let view = KernelArgumentValueViewHelper.view(for: type).init(frame: valueSelectionContainer.bounds, value: value) as? (UIView & KernelArgumentValueView) {
            stackView.axis = view.prefferedUIAxis
            valueSelectionContainer.removeFromSuperview()
            if view.prefferedUIAxis == .horizontal {
                stackView.addArrangedSubview(valueSelectionContainer)
            } else {
                stackView.insertArrangedSubview(valueSelectionContainer, at: 0)
            }
            valueSelectionView?.removeFromSuperview()
            valueSelectionContainer.addSubview(view)
            valueSelectionView = view
            valueSelectionView?.updatedValueCallback = { [weak self] value in
                self?.valueSelectionChanged(value: value)
            }
            layoutIfNeeded()
        }
        valueSelectionHeight.constant = CGFloat(valueSelectionView?.prefferedHeight ?? 0)
        layoutIfNeeded()
    }

    func valueSelectionChanged(value: KernelArgumentValue) {
        attribute?.value = value
        print(valueSelectionView!.prefferedHeight)
        valueSelectionHeight.constant = CGFloat(valueSelectionView!.prefferedHeight)
        layoutIfNeeded()
        updateCallBack?(self, attribute!)
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

extension KernelArgumentType: SelectObjectViewControllerPresentable {
    var title: String {
        return rawValue
    }

    var subtitle: String? {
        return nil
    }

    var interactionEnabled: Bool {
        return true
    }

    var image: UIImage? {
        return nil
    }
}

extension DataBinding: SelectObjectViewControllerPresentable {
    var title: String {
        return String(describing: self)
    }

    var subtitle: String? {
        return nil
    }

    var image: UIImage? {
        return nil
    }

    var interactionEnabled: Bool {
        return true
    }
}

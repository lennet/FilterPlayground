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
    @IBOutlet weak var valueSelectionView: UIView!
    @IBOutlet weak var newArgumentOverlay: UIView!
    @IBOutlet weak var dataBindingButton: UIButton!

    var valueButton: UIView!

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
            } else {
                valueSelectionView.subviews.forEach { $0.removeFromSuperview() }
                nameTextField.text = nil
                nameTextField.isEnabled = false
                newArgumentOverlay.isHidden = false
            }
        }
    }

    var updateCallBack: ((UITableViewCell, KernelArgument) -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()
        registerNotifications()
        nameTextField.delegate = self
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

    @IBAction func dataBindingButtonTapped(_: UIButton) {
    }

    func presentTypeSelection(with sender: UIButton) {
        let viewController = UIStoryboard(name: "ValuePicker", bundle: nil).instantiateViewController(withIdentifier: "selectTypeViewControllerIdentifier") as! SelectTypeViewController
        viewController.didSelectType = { type in
            self.attribute = KernelArgument(name: self.attribute?.name ?? "", type: type, value: type.defaultValue)
            self.setupValueView(for: type, value: self.attribute!.value)
            self.update()
            if self.nameTextField.text?.isEmpty ?? true {
                DispatchQueue.main.async {
                    self.nameTextField.becomeFirstResponder()
                }
            }
        }
        present(viewController: viewController, with: sender)
    }

    @objc func valueButtonTapped(sender: UIButton) {
        let viewController = UIStoryboard(name: "ValuePicker", bundle: nil).instantiateViewController(withIdentifier: "SelectFloatViewControllerIdentifier") as! FloatPickerViewController
        valueButton = sender
        viewController.valueChanged = { value in
            self.attribute?.value = .float(Float(value))
            (self.valueButton as? UIButton)?.setTitle("\(value)", for: .normal)
            self.updateCallBack?(self, self.attribute!)
        }
        present(viewController: viewController, with: sender)
    }

    @objc func colorButtonTapped(sender _: UIButton) {
        let viewController = UIStoryboard(name: "ValuePicker", bundle: nil).instantiateViewController(withIdentifier: "ColorPickerViewControllerIdentifier") as! ColorPickerViewController
        viewController.colorChanged = { r, g, b, a in
            self.attribute?.value = .color(r, g, b, a)
            self.valueButton.backgroundColor = UIColor(displayP3Red: CGFloat(r), green: CGFloat(g), blue: CGFloat(b), alpha: CGFloat(a))
            self.updateCallBack?(self, self.attribute!)
        }
        present(viewController: viewController, with: valueSelectionView)
    }

    func setupValueView(for type: KernelArgumentType, value _: KernelAttributeValue?) {
        valueSelectionView.subviews.forEach { $0.removeFromSuperview() }
        switch (type, attribute?.value) {
        case let (.sample, .sample(image)?) :
            let imageView = CustomImageView(frame: valueSelectionView.bounds)
            imageView.didSelectImage = { image in
                self.attribute?.value = .sample(image.image!.asCIImage!)
                self.updateCallBack?(self, self.attribute!)
            }
            imageView.image = UIImage(ciImage: image)
            imageView.backgroundColor = .gray
            valueSelectionView.addSubview(imageView)
            break
        case let (.color, .color(r, g, b, a)?):
            let button = UIButton(frame: valueSelectionView.bounds)
            valueSelectionView.addSubview(button)
            button.backgroundColor = UIColor(displayP3Red: CGFloat(r), green: CGFloat(g), blue: CGFloat(b), alpha: CGFloat(a))
            button.addTarget(self, action: #selector(colorButtonTapped(sender:)), for: .touchUpInside)
            valueButton = button
            break
        case let (.vec2, .vec2(a, b)?):
            let picker = VectorValuePicker(frame: valueSelectionView.bounds, values: [a, b])
            picker.valuesChanged = { values in
                self.attribute?.value = .vec2(values[0], values[1])
                self.updateCallBack?(self, self.attribute!)
            }
            valueButton = picker
            valueSelectionView.addSubview(picker)
        case let (.vec3, .vec3(a, b, c)?):
            let picker = VectorValuePicker(frame: valueSelectionView.bounds, values: [a, b, c])
            picker.valuesChanged = { values in
                self.attribute?.value = .vec3(values[0], values[1], values[2])
                self.updateCallBack?(self, self.attribute!)
            }
            valueButton = picker
            valueSelectionView.addSubview(picker)
        case let (.vec4, .vec4(a, b, c, d)?):
            let picker = VectorValuePicker(frame: valueSelectionView.bounds, values: [a, b, c, d])
            picker.valuesChanged = { values in
                self.attribute?.value = .vec4(values[0], values[1], values[2], values[3])
                self.updateCallBack?(self, self.attribute!)
            }
            valueButton = picker
            valueSelectionView.addSubview(picker)
        case let (.float, .float(floatValue)?):
            let button = UIButton(frame: valueSelectionView.bounds)
            valueSelectionView.addSubview(button)
            button.addTarget(self, action: #selector(valueButtonTapped(sender:)), for: .touchUpInside)
            button.setTitleColor(.blue, for: .normal)
            button.setTitle("\(floatValue)", for: .normal)
            valueButton = button
            break
        default:
            break
        }
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

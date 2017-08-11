//
//  KernelAttributeTableViewCell.swift
//  FilterPlayground
//
//  Created by Leo Thomas on 29.07.17.
//  Copyright © 2017 Leo Thomas. All rights reserved.
//

import UIKit

class KernelAttributeTableViewCell: UITableViewCell {
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var typeButton: UIButton!
    @IBOutlet weak var valueSelectionView: UIView!
    
    var valueButton: UIButton!
    
    var attribute: KernelAttribute? {
        didSet {
            if let type = attribute?.type {
                setupValueView(for: type, value: attribute?.value)
                typeButton.setTitle(type.rawValue, for: .normal)
            } else {
                typeButton.setTitle("type", for: .normal)
                valueSelectionView.subviews.forEach{ $0.removeFromSuperview() }
            }
            update()
        }
    }

    var updateCallBack: ((UITableViewCell, KernelAttribute) -> ())?

    @IBAction func nameTextFieldChanged(_ sender: Any) {
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
//        guard attribute.type != nil,
//            !attribute.name.isEmpty,
//            attribute.value != nil else {
//            return
//        }
  
        updateCallBack?(self, attribute)
       
    }
    
    @IBAction func selectType(_ sender: UIButton) {

        let viewController = UIStoryboard(name: "ValuePicker", bundle: nil).instantiateViewController(withIdentifier: "selectTypeViewControllerIdentifier") as! SelectTypeViewController
        
        viewController.modalPresentationStyle = .popover
        viewController.popoverPresentationController?.sourceView = sender
        viewController.popoverPresentationController?.sourceRect = sender.bounds
        viewController.didSelectType = { type in
            self.attribute = KernelAttribute(name: self.attribute?.name ?? "", type: type, value: type.defaultValue)
            self.setupValueView(for: type, value: self.attribute!.value)
        }
        UIApplication.shared.keyWindow?.rootViewController?.presentedViewController?.present(viewController, animated: true, completion: nil)
    }
    
    @objc func valueButtonTapped(sender: UIButton) {
        let viewController = UIStoryboard(name: "ValuePicker", bundle: nil).instantiateViewController(withIdentifier: "SelectFloatViewControllerIdentifier") as! SelectFloatViewController
        self.valueButton = sender
        viewController.valueChanged = { value in
            self.attribute?.value = .float(Float(value))
            self.updateCallBack?(self, self.attribute!)
        }
        
        viewController.modalPresentationStyle = .popover
        viewController.popoverPresentationController?.sourceView = valueSelectionView
        viewController.popoverPresentationController?.sourceRect = valueSelectionView.bounds
        
        UIApplication.shared.keyWindow?.rootViewController?.presentedViewController?.present(viewController, animated: true, completion: nil)
    }
    
    @objc func colorButtonTapped(sender: UIButton) {
        let viewController = UIStoryboard(name: "ValuePicker", bundle: nil).instantiateViewController(withIdentifier: "ColorPickerViewControllerIdentifier") as! ColorPickerViewController
        viewController.colorChanged = { r, g ,b , a in
            self.attribute?.value = .color(r,g,b,a)
            self.updateCallBack?(self, self.attribute!)
        }
        
        viewController.modalPresentationStyle = .popover
        viewController.popoverPresentationController?.sourceView = valueSelectionView
        viewController.popoverPresentationController?.sourceRect = valueSelectionView.bounds
        
        UIApplication.shared.keyWindow?.rootViewController?.presentedViewController?.present(viewController, animated: true, completion: nil)
    }
    
    func setupValueView(for type: KernelAttributeType, value: KernelAttributeValue?) {
        valueSelectionView.subviews.forEach{ $0.removeFromSuperview() }
        switch type {
        case .sample :
            let imageView = SelectImageView(frame: valueSelectionView.bounds)
            imageView.didSelectImage = { image in
                self.attribute?.value = .sample(image.image!)
                self.updateCallBack?(self, self.attribute!)
            }
            if case .sample(let image)? = value {
                imageView.image = image
            }
            
            imageView.backgroundColor = .gray
            valueSelectionView.addSubview(imageView)
            break
        case .color:
            let button = UIButton(frame: valueSelectionView.bounds)
            valueSelectionView.addSubview(button)
            if case .color(let r, let g , let b , let a)? = value {
                button.backgroundColor = UIColor(displayP3Red: CGFloat(r), green: CGFloat(g), blue: CGFloat(b), alpha: CGFloat(a))
            }
            button.addTarget(self, action: #selector(colorButtonTapped(sender:)), for: .touchUpInside)
            valueButton = button
            break
        default:
            let button = UIButton(frame: valueSelectionView.bounds)
            valueSelectionView.addSubview(button)
            button.addTarget(self, action: #selector(valueButtonTapped(sender:)), for: .touchUpInside)
            button.setTitle("0.0", for: .normal)
            button.setTitleColor(.blue, for: .normal)
            if case .float(let floatValue)? = value {
                button.setTitle("\(floatValue)", for: .normal)
            } else {
                button.setTitle("0.0", for: .normal)
            }
            valueButton = button
            break
        }
    }
    
}

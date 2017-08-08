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
    
    var attribute: KernelAttribute? {
        didSet {
            if let type = attribute?.type {
                typeButton.setTitle("\(type)", for: .normal)
                setupValueView(for: type)
            } else {
                typeButton.setTitle("select type", for: .normal)
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
        guard attribute.type != nil,
            !attribute.name.isEmpty,
            attribute.value != nil else {
            return
        }
  
        updateCallBack?(self, attribute)
       
    }
    
    @IBAction func selectType(_ sender: UIButton) {

        let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "selectTypeViewControllerIdentifier") as! SelectTypeViewController
        
        viewController.modalPresentationStyle = .popover
        viewController.popoverPresentationController?.sourceView = sender
        viewController.popoverPresentationController?.sourceRect = sender.bounds
        viewController.didSelectType = { type in
            self.attribute = KernelAttribute(name: self.attribute?.name ?? "", type: type, value: nil)
        }
        UIApplication.shared.keyWindow?.rootViewController?.present(viewController, animated: true, completion: nil)
    }
    
    @objc func valueButtonTapped(sender: UIButton) {
        let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SelectFloatViewControllerIdentifier") as! SelectFloatViewController
        
        viewController.valueChanged = { value in
            
            let title = "\(value.description)"
            sender.setTitle(title, for: .normal)
        }
        
        viewController.modalPresentationStyle = .popover
        viewController.popoverPresentationController?.sourceView = sender
        viewController.popoverPresentationController?.sourceRect = sender.bounds
        
        UIApplication.shared.keyWindow?.rootViewController?.present(viewController, animated: true, completion: nil)
    }
    
    func setupValueView(for type: KernelAttributeType) {
        valueSelectionView.subviews.forEach{ $0.removeFromSuperview() }
        switch type {
        case .sample :
            let imageView = SelectImageView(frame: valueSelectionView.bounds)
            imageView.backgroundColor = .gray
            valueSelectionView.addSubview(imageView)
            break
        default:
            let button = UIButton(frame: valueSelectionView.bounds)
            valueSelectionView.addSubview(button)
            button.addTarget(self, action: #selector(valueButtonTapped(sender:)), for: .touchUpInside)
            button.setTitle("0.0", for: .normal)
            button.setTitleColor(.blue, for: .normal)
            break
        }
    }

}

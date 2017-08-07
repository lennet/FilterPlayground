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

    
    var attribute: KernelAttribute? {
        didSet {
            if let type = attribute?.type {
                typeButton.setTitle("\(type)", for: .normal)
            } else {
                typeButton.setTitle("select type", for: .normal)
            }
            update()
        }
    }

    var updateCallBack: ((UITableViewCell, KernelAttribute) -> ())?
    var peromSegueCallBack: ((String, Any?) -> ())?

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
    
    @IBAction func selectType(_ sender: Any) {
        peromSegueCallBack?("SelectType", self)
    }

}

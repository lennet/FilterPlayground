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
    @IBOutlet weak var identifierTextField: UITextField!
    
    var attribute: KernelAttribute?

    var updateCallBack: ((UITableViewCell, KernelAttribute) -> ())?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        }

    @IBAction func identifierTextFieldChanged(_ sender: Any) {
        update()
    }
    
    @IBAction func nameTextFieldChanged(_ sender: Any) {
        update()
    }
    
    func update() {
        guard let identifier = identifierTextField.text,
            let name = nameTextField.text else {
                return
        }
        guard !identifier.isEmpty,
            !name.isEmpty else {
                return
        }
        
        attribute = KernelAttribute.unkwon(identifier: identifier, value: name)
        updateCallBack?(self, attribute!)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

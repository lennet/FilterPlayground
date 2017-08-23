//
//  ErrorTableViewCell.swift
//  FilterPlayground
//
//  Created by Leo Thomas on 31.07.17.
//  Copyright © 2017 Leo Thomas. All rights reserved.
//

import UIKit

class ErrorTableViewCell: UITableViewCell {

    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var errorView: UIView!
    
    var error: KernelError? {
        didSet {
            setup()
        }
    }
    
    func setup()
    {
        guard let error = error else { return }
        switch error {
        case .compile(lineNumber: _, characterIndex: _, type: let type, message: let message, note: _):
            label.text = "\(type): \(message)"
            errorView.backgroundColor = .red
            break
        case .runtime(message: let message):
            label.text = "\(message)"
            errorView.backgroundColor = .purple
            break
        }
    }
    
}

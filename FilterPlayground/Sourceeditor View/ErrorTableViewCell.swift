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
    @IBOutlet weak var errorView: UIImageView!

    var error: KernelError? {
        didSet {
            setup()
        }
    }

    func setup() {
        guard let error = error else { return }
        switch error {
        case .compile(lineNumber: _, characterIndex: _, type: let type, message: let message, note: let note):
            var text = "\(type): \(message)"
            if let note = note {
                text.append("\n\(note.message)")
            }
            label.text = text
            errorView.image = #imageLiteral(resourceName: "CompileError")
            break
        case let .runtime(message: message):
            label.text = "\(message)"
            errorView.image = #imageLiteral(resourceName: "RunTimeError")
            break
        }
    }
    
}

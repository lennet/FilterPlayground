//
//  ErrorTableViewCell.swift
//  FilterPlayground
//
//  Created by Leo Thomas on 31.07.17.
//  Copyright © 2017 Leo Thomas. All rights reserved.
//

import UIKit

extension CompileErrorType {

    var icon: UIImage? {
        switch self {
        case .error:
            return #imageLiteral(resourceName: "CompileError")
        case .warning:
            return #imageLiteral(resourceName: "CompilerWarning")
        case .note:
            return nil
        }
    }
}

class ErrorTableViewCell: UITableViewCell {

    @IBOutlet var label: UILabel!
    @IBOutlet var errorView: UIImageView!

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
            errorView.image = type.icon
            break
        case let .runtime(message: message):
            label.text = "\(message)"
            errorView.image = #imageLiteral(resourceName: "RunTimeError")
            break
        }
    }
}

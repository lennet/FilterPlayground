//
//  CodeCompletionCollectionViewCell.swift
//  FilterPlayground
//
//  Created by Leo Thomas on 25.09.17.
//  Copyright © 2017 Leo Thomas. All rights reserved.
//

import UIKit

class CodeCompletionCollectionViewCell: UICollectionViewCell {
    class var reuseIdentifier: String {
        return String(describing: CodeCompletionCollectionViewCell.self)
    }

    fileprivate weak var label: UILabel?

    var text: String? {
        get {
            return label?.text
        }
        set {
            configureLabel()
            label?.text = newValue
        }
    }

    func configureLabel() {
        guard self.label == nil else { return }
        let label = UILabel(frame: bounds)
        label.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        label.textAlignment = .center
        addSubview(label)
        self.label = label
    }
}

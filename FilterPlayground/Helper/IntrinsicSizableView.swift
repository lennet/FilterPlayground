//
//  IntrinsicSizableView.swift
//  FilterPlayground
//
//  Created by Leo Thomas on 17.04.18.
//  Copyright © 2018 Leo Thomas. All rights reserved.
//

import UIKit

class IntrinsicSizableView: UIView {
    override var intrinsicContentSize: CGSize {
        return customIntrinsicContentSize
    }

    var customIntrinsicContentSize: CGSize = CGSize(width: -1, height: -1) {
        didSet {
            invalidateIntrinsicContentSize()
        }
    }
}

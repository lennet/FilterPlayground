//
//  ViewControllerWithIntrinsicContentSize.swift
//  FilterPlayground
//
//  Created by Leo Thomas on 17.04.18.
//  Copyright © 2018 Leo Thomas. All rights reserved.
//

import UIKit

class ViewControllerWithIntrinsicContentSize: UIViewController {
    override var preferredContentSize: CGSize {
        set {
            (view as? IntrinsicSizableView)?.customIntrinsicContentSize = newValue
        }
        get {
            return (view as? IntrinsicSizableView)?.customIntrinsicContentSize ?? CGSize(width: -1, height: -1)
        }
    }
}

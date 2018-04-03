//
//  DataBinding+SelectObjectViewControllerRepresentable.swift
//  FilterPlayground
//
//  Created by Leo Thomas on 03.04.18.
//  Copyright © 2018 Leo Thomas. All rights reserved.
//

import UIKit

extension DataBinding: SelectObjectViewControllerPresentable {
    var title: String {
        return String(describing: self)
    }

    var subtitle: String? {
        return nil
    }

    var image: UIImage? {
        return nil
    }

    var interactionEnabled: Bool {
        return true
    }
}

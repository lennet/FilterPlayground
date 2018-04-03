//
//  KernelArgumentType+SelectObjectViewControllerRepresentable.swift
//  FilterPlayground
//
//  Created by Leo Thomas on 03.04.18.
//  Copyright © 2018 Leo Thomas. All rights reserved.
//

import UIKit

extension KernelArgumentType: SelectObjectViewControllerPresentable {
    var title: String {
        return rawValue
    }

    var subtitle: String? {
        return nil
    }

    var interactionEnabled: Bool {
        return true
    }

    var image: UIImage? {
        return nil
    }
}

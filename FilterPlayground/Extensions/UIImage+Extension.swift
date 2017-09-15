//
//  UIImage+Extension.swift
//  FilterPlayground
//
//  Created by Leo Thomas on 12.09.17.
//  Copyright © 2017 Leo Thomas. All rights reserved.
//

import UIKit

extension UIImage {

    var asCIImage: CIImage? {
        return ciImage ?? CIImage(cgImage: cgImage!)
    }
}

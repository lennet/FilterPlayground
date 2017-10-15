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
        return (ciImage ?? CIImage(cgImage: cgImage!)).oriented(forExifOrientation: exifOrientation)
    }

    var exifOrientation: Int32 {
        switch imageOrientation {
        case .up:
            return 1
        case .upMirrored:
            return 2
        case .down:
            return 3
        case .downMirrored:
            return 4
        case .leftMirrored:
            return 5
        case .right:
            return 6
        case .rightMirrored:
            return 7
        case .left:
            return 8
        }
    }
}

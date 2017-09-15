//
//  CoreImage+Extension.swift
//  FilterPlayground
//
//  Created by Leo Thomas on 12.09.17.
//  Copyright © 2017 Leo Thomas. All rights reserved.
//

#if os(iOS) || os(tvOS)
    import UIKit
#elseif os(OSX)
    import AppKit
#endif

extension CIImage {

    var asPNGData: Data? {
        #if os(iOS) || os(watchOS) || os(tvOS)
            let context = CIContext()
            let image: UIImage
            if let cgImage = context.createCGImage(self, from: self.extent) {
                image = UIImage(cgImage: cgImage)
            } else {
                image = UIImage(ciImage: self)
            }
            return UIImagePNGRepresentation(image)
        #elseif os(OSX)
            // TODO:
            return nil
        #else
            return nil
        #endif
    }
}

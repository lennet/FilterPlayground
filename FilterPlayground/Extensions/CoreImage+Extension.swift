//
//  CoreImage+Extension.swift
//  FilterPlayground
//
//  Created by Leo Thomas on 12.09.17.
//  Copyright © 2017 Leo Thomas. All rights reserved.
//

#if os(iOS) || os(tvOS)
    import UIKit
    typealias Image = UIImage
#elseif os(OSX)
    import AppKit
    typealias Image = NSImage
#endif

extension CIImage {

    var asJPGData: Data? {
        #if os(iOS) || os(watchOS) || os(tvOS)
            let context = CIContext()
            let image: UIImage
            if let cgImage = context.createCGImage(self, from: self.extent) {
                image = UIImage(cgImage: cgImage)
            } else {
                image = UIImage(ciImage: self)
            }
            return UIImageJPEGRepresentation(image, 1.0)
        #elseif os(OSX)
            // TODO:
            return nil
        #else
            return nil
        #endif
    }

    var asImage: Image? {
        #if os(iOS) || os(watchOS) || os(tvOS)
            let context = CIContext()
            if let cgImage = context.createCGImage(self, from: self.extent) {
                return UIImage(cgImage: cgImage)
            } else {
                return UIImage(ciImage: self)
            }
        #else
            let context = CIContext()
            if let cgImage = context.createCGImage(self, from: self.extent) {
                return NSImage(cgImage: cgImage, size: extent.size)
            }
            return nil
        #endif
    }
}

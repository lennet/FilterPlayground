//
//  UIImage+Extension.swift
//  FilterPlayground
//
//  Created by Leo Thomas on 12.09.17.
//  Copyright © 2017 Leo Thomas. All rights reserved.
//

import MetalKit
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

    convenience init?(texture: MTLTexture) {

        let byteCount = texture.width * texture.height * 4

        guard let imageBytes = malloc(byteCount) else {
            return nil
        }
        let bytesPerRow = texture.width * 4
        let region = MTLRegionMake2D(0, 0, texture.width, texture.height)
        texture.getBytes(imageBytes, bytesPerRow: bytesPerRow, from: region, mipmapLevel: 0)

        let freeDataCallBack: CGDataProviderReleaseDataCallback = { (_: UnsafeMutableRawPointer?, _: UnsafeRawPointer, _: Int) -> Void in
        }

        guard let dataProvider = CGDataProvider(dataInfo: nil, data: imageBytes, size: byteCount, releaseData: freeDataCallBack) else {
            return nil
        }

        let bitsPerComponent = 8
        let bitsPerPixel = 32

        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGImageAlphaInfo.noneSkipFirst.rawValue | CGBitmapInfo.byteOrder32Little.rawValue

        let renderingIndent = CGColorRenderingIntent.defaultIntent

        guard let image = CGImage(width: texture.width, height: texture.height, bitsPerComponent: bitsPerComponent, bitsPerPixel: bitsPerPixel, bytesPerRow: bytesPerRow, space: colorSpace, bitmapInfo: CGBitmapInfo(rawValue: bitmapInfo), provider: dataProvider, decode: nil, shouldInterpolate: true, intent: renderingIndent) else {
            return nil
        }

        self.init(cgImage: image)
    }
}

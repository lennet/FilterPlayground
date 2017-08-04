//
//  Extensions.swift
//  FilterPlayground
//
//  Created by Leo Thomas on 31.07.17.
//  Copyright © 2017 Leo Thomas. All rights reserved.
//

import UIKit

extension NSAttributedString {

    static func +(lhs: NSAttributedString, rhs: NSAttributedString) -> NSAttributedString
    {
        let result = NSMutableAttributedString()
        result.append(lhs)
        result.append(rhs)
        return result
    }

}

extension UIFont {
    
    var monospacedDigitFont: UIFont {
        let fontDescriptorFeatureSetting = [UIFontDescriptor.FeatureKey.featureIdentifier: kNumberSpacingType, UIFontDescriptor.FeatureKey.typeIdentifier: kMonospacedNumbersSelector]
        let monospacedFontDescriptor = fontDescriptor.addingAttributes([UIFontDescriptor.AttributeName.featureSettings: [fontDescriptorFeatureSetting]])
        return UIFont(descriptor: monospacedFontDescriptor, size: pointSize)
    }
    
}

extension String {
    
    var firstLine: String? {
        return self.components(separatedBy: "\n").first
    }
        
}

extension FileManager {
    
    static func urlInDocumentsDirectory(for name: String) -> URL {
        let documentsPath = NSSearchPathForDirectoriesInDomains(
            .documentDirectory,
            .userDomainMask,
            true)[0]
        return URL(fileURLWithPath: "\(documentsPath)/\(name)")
    }
    
}

extension CIWarpKernel: Kernel {
    
    static func compile(source: String) -> Kernel? {
        return CIWarpKernel(source: source)
    }
    
    func apply(to image: UIImage, attributes: [KernelAttribute]) -> UIImage? {
        
        guard let input = CIImage(image: image) else {
            return nil
            
        }
        
        guard let result = self.apply(extent: input.extent, roiCallback: { (index, rect) -> CGRect in
            return rect
        }, image: input, arguments: attributes.flatMap{ $0.value }) else {
            return nil
        }
        return UIImage(ciImage: result)
    }

}

extension CIColorKernel: Kernel {
    
    static func compile(source: String) -> Kernel? {
        return CIColorKernel(source: source)
    }
    
    func apply(to image: UIImage, attributes: [KernelAttribute]) -> UIImage? {
        
        guard let input = CIImage(image: image) else {
            return nil
            
        }
        
        guard let result = self.apply(extent: input.extent, arguments: [input] + attributes.flatMap{ $0.value }) else {
            return nil
        }
        return UIImage(ciImage: result)
    }
    
}

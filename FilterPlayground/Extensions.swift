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
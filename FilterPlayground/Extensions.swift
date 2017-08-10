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
    
    func apply(to image: UIImage, attributes: [Any]) -> UIImage? {
        
        guard let input = CIImage(image: image) else {
            return nil
        }
        
        guard let result = self.apply(extent: input.extent, roiCallback: { (index, rect) -> CGRect in
            return rect
        }, image: input, arguments: attributes) else {
            return nil
        }
        return UIImage(ciImage: result)
    }

}

extension CIColorKernel: Kernel {
    
    static func compile(source: String) -> Kernel? {
        return CIColorKernel(source: source)
    }
    
    func apply(to image: UIImage, attributes: [Any]) -> UIImage? {
        
        guard let input = CIImage(image: image) else {
            return nil
        }
        
        let arguments =  [input as Any]
        guard let result = self.apply(extent: input.extent, roiCallback: { (index, rect) -> CGRect in
            return rect
        }, arguments: arguments) else {
            return nil
        }
        return UIImage(ciImage: result)
    }
    
}

extension Array where Element: Equatable {
    
    func index(of element: Element, after index: Int) -> Int? {
        for i in index..<self.count {
            if self[i] == element {
                return i
            }
        }
        return nil
    }
    
}

extension CGFloat {
    
    var asRadian: CGFloat {
        return self * CGFloat.pi / 180
    }
    
}

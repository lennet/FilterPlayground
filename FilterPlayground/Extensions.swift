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
    
    var withoutWhiteSpaces: String {
        return self.replacingOccurrences(of: " ", with: "")
    }
    
    var withoutSlash: String {
        return self.replacingOccurrences(of: "/", with: "")
    }
    
    var numberOfLines: Int {
        return self.components(separatedBy: "\n").count
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
    
    func apply(with inputImages: [UIImage], attributes: [Any]) -> UIImage? {
        
        guard let input = (inputImages.flatMap{ $0.asCIImage }).first else {
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
    
    func apply(with inputImages: [UIImage], attributes: [Any]) -> UIImage? {
        guard let image = attributes.first as? CISampler else {
            return nil
        }
        
        guard let result = self.apply(extent: image.extent, arguments: attributes) else {
            return nil
        }
        return UIImage(ciImage: result)
    }
    
}

public func ==<A: Equatable, B: Equatable>(lhs: [(A, B)], rhs: [(A, B)]) -> Bool {
    guard lhs.count == rhs.count else { return false }
    return zip(lhs, rhs)
        .filter{ $0.0 != $1.0 || $0.1 != $1.1 }
        .count == 0
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
    
    func indexCountingFromLastElement(of element: Element) -> Int? {
        
        for i in stride(from: self.count-1, to: 0, by: -1) {
            if self[i] == element {
                return i
            }
        }
        return nil
    }
    
    mutating func replace(element: Element, with replacement: Element) {
        self = map{
            if $0 == element {
                return replacement
            }
            return $0
        }
    }
}

extension CGFloat {
    
    var asRadian: CGFloat {
        return self * CGFloat.pi / 180
    }
    
}

extension UIImage {
    
    var asCIImage: CIImage? {
        return ciImage ?? CIImage(cgImage: cgImage!)
    }
    
}

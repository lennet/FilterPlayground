//
//  Extensions.swift
//  FilterPlayground
//
//  Created by Leo Thomas on 31.07.17.
//  Copyright © 2017 Leo Thomas. All rights reserved.
//

import CoreGraphics
import Foundation

extension NSAttributedString {

    static func +(lhs: NSAttributedString, rhs: NSAttributedString) -> NSAttributedString {
        let result = NSMutableAttributedString()
        result.append(lhs)
        result.append(rhs)
        return result
    }
}

extension String {

    var firstLine: String? {
        return components(separatedBy: "\n").first
    }

    var withoutWhiteSpaces: String {
        return replacingOccurrences(of: " ", with: "")
    }

    var withoutSlash: String {
        return replacingOccurrences(of: "/", with: "")
    }

    var numberOfLines: Int {
        return components(separatedBy: "\n").count
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

public func ==<A: Equatable, B: Equatable>(lhs: [(A, B)], rhs: [(A, B)]) -> Bool {
    guard lhs.count == rhs.count else { return false }
    return zip(lhs, rhs)
        .filter { $0.0 != $1.0 || $0.1 != $1.1 }
        .count == 0
}

extension Array where Element: Equatable {

    func index(of element: Element, after index: Int) -> Int? {
        for i in index ..< count {
            if self[i] == element {
                return i
            }
        }
        return nil
    }

    func indexCountingFromLastElement(of element: Element) -> Int? {

        for i in stride(from: count - 1, to: 0, by: -1) {
            if self[i] == element {
                return i
            }
        }
        return nil
    }

    mutating func replace(element: Element, with replacement: Element) {
        self = map {
            if $0 == element {
                return replacement
            }
            return $0
        }
    }
}

extension Array {
    func appending(with array: Array<Element>) -> Array<Element> {
        var tmp = self
        tmp.append(contentsOf: array)
        return tmp
    }
}

extension CGFloat {

    var asRadian: CGFloat {
        return self * CGFloat.pi / 180
    }

    func noramlized(min: CGFloat, max: CGFloat) -> CGFloat {
        return (self - min) / (max - min)
    }
}

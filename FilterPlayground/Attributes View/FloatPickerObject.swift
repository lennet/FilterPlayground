//
//  FloatPickerObject.swift
//  FilterPlayground
//
//  Created by Leo Thomas on 08.04.18.
//  Copyright © 2018 Leo Thomas. All rights reserved.
//

import Foundation

enum FloatPickerObjectInput: Equatable {
    case digit(Int)
    case dot

    var digitValue: Int? {
        switch self {
        case let .digit(value):
            return value
        case .dot:
            return nil
        }
    }
}

struct FloatPickerObject: ExpressibleByFloatLiteral {
    typealias FloatLiteralType = Float

    private var sign: FloatingPointSign
    private var inputs: [FloatPickerObjectInput]

    init(floatLiteral value: Float) {
        inputs = []
        sign = value.sign
        set(value: value)
    }

    init() {
        sign = .plus
        inputs = []
    }

    mutating func set(value: Float) {
        if value == 0 {
            self.inputs = []
            return
        }
        let string = String(value)
        let splits = string.split(separator: ".", maxSplits: 2, omittingEmptySubsequences: false)
        var inputs = splits[0].compactMap({ Int(String($0)) }).map({ val in
            FloatPickerObjectInput.digit(val)
        })

        if splits.count > 1 {
            inputs.append(.dot)
            inputs.append(contentsOf: splits[1].compactMap({ Int(String($0)) }).map({ val in
                FloatPickerObjectInput.digit(val)
            }))
        }

        self.inputs = inputs
    }

    mutating func add(input: FloatPickerObjectInput) {
        if input == .dot && containsDot {
            return
        }
        inputs.append(input)
    }

    mutating func toggleSign() {
        switch sign {
        case .minus:
            sign = .plus
            break
        case .plus:
            sign = .minus
            break
        }
    }

    mutating func removeLastInput() {
        guard inputs.count > 0 else { return }
        inputs.removeLast()
    }

    var containsDot: Bool {
        return inputs.filter({ (val) -> Bool in
            val == .dot
        }).count > 1
    }

    var floatRepresentation: Float {
        let splits = inputs.split(separator: .dot, maxSplits: 2, omittingEmptySubsequences: false).map { Array($0) }
        let first = splits[0]

        func getPart(digits: [FloatPickerObjectInput]) -> Int {
            return digits.compactMap { $0.digitValue }
                .reversed()
                .enumerated()
                .map { (arg) -> Int in
                    let (index, value) = arg

                    return Int(Float(pow(10.0, Float(index)) * Float(value))) }.reduce(0, +)
        }

        var result = Float(getPart(digits: splits[0]))
        if splits.count == 2 {
            let decimals = splits[1]
            result += Float(getPart(digits: decimals)) / Float(pow(10.0, Float(decimals.count)))
        }
        return sign == .minus ? -result : result
    }

    var stringRepresentation: String {
        guard inputs.count > 0 else {
            return "0"
        }
        return (sign == .minus ? "-" : "") + inputs.map { (input) -> String in
            switch input {
            case let .digit(val):
                return String(val)
            case .dot:
                return "."
            }
        }.joined()
    }
}

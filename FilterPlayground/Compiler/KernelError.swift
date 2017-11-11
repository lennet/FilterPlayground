//
//  CompilerError.swift
//  FilterPlayground
//
//  Created by Leo Thomas on 04.08.17.
//  Copyright © 2017 Leo Thomas. All rights reserved.
//

import Foundation

enum CompileErrorType: String {
    case error
    case note
    case warning
}

enum KernelError {
    case compile(lineNumber: Int, characterIndex: Int, type: CompileErrorType, message: String, note: (lineNumber: Int, characterIndex: Int, message: String)?)
    case runtime(message: String)

    var isRuntime: Bool {
        switch self {
        case .compile(lineNumber: _, characterIndex: _, type: _, message: _, note: _):
            return false
        case .runtime(message: _):
            return true
        }
    }

    var isWarning: Bool {
        switch self {
        case .compile(lineNumber: _, characterIndex: _, type: let type, message: _, note: _):
            return type == .warning
        case .runtime(message: _):
            return false
        }
    }
}

extension KernelError: Equatable {

    static func == (lhs: KernelError, rhs: KernelError) -> Bool {
        switch (lhs, rhs) {
        case let (.runtime(lMessage), .runtime(message: rMessage)):
            return lMessage == rMessage
        case let (.compile(lLineNumber, lCharacterIndex, lType, lMessage, lNote), .compile(rLineNumber, rCharacterIndex, rType, rMessage, rNote)):
            return lLineNumber == rLineNumber &&
                lCharacterIndex == rCharacterIndex &&
                lType == rType &&
                lMessage == rMessage &&
                lNote ?? (0, 0, "") == rNote ?? (0, 0, "")
        default:
            return false
        }
    }
}

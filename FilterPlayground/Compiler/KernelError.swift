//
//  CompilerError.swift
//  FilterPlayground
//
//  Created by Leo Thomas on 04.08.17.
//  Copyright © 2017 Leo Thomas. All rights reserved.
//

import Foundation

enum KernelError {
    case compile(lineNumber: Int, characterIndex: Int, type: String, message: String, note: (Int, Int, String)?)
    case runtime(message: String)
}

extension KernelError: Equatable {
    
    static func ==(lhs: KernelError, rhs: KernelError) -> Bool {
        switch (lhs, rhs) {
        case (.runtime(let lMessage), .runtime(message: let rMessage)):
            return lMessage == rMessage
        case (.compile(let lLineNumber, let lCharacterIndex, let lType, let lMessage, let lNote), .compile(let rLineNumber, let rCharacterIndex, let rType, let rMessage, let rNote)):
            return lLineNumber == rLineNumber &&
            lCharacterIndex == rCharacterIndex &&
            lType == rType &&
            lMessage == rMessage &&
            lNote ?? (0,0,"") == rNote ?? (0,0,"")
        default:
            return false
        }
    }
    
}

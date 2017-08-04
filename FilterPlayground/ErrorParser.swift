//
//  ErrorParser.swift
//  FilterPlayground
//
//  Created by Leo Thomas on 31.07.17.
//  Copyright © 2017 Leo Thomas. All rights reserved.
//

import Foundation

struct CompilerError {
    var lineNumber: Int
    var characterIndex: Int
    var type: String
    var message: String
}

extension CompilerError: Equatable {
    
    static func ==(lhs: CompilerError, rhs: CompilerError) -> Bool {
        return lhs.lineNumber == rhs.lineNumber &&
        lhs.characterIndex == rhs.characterIndex &&
        lhs.type == rhs.type &&
        lhs.message == rhs.message
    }
    
}

class ErrorParser {
    
    private init() {}
    
    class func getErrors(for errorString: String) -> [CompilerError] {
        let components = errorString.components(separatedBy: "[CIKernelPool]").flatMap{ $0.firstLine }
        let errors = components.flatMap(getError)
        return errors
    }
    
    fileprivate class func getError(for errorString: String) -> CompilerError? {
        let components = errorString.components(separatedBy: ":").map{ $0.trimmingCharacters(in: CharacterSet.whitespaces) }
        guard components.count == 4 else { return nil }
        
        guard let lineNumber = Int(components[0]) else { return nil }
        guard let characterIndex = Int(components[1]) else { return nil }
        let type = components[2]
        let message = components[3]
        
        return CompilerError(lineNumber: lineNumber, characterIndex: characterIndex, type: type, message: message)
    }
    
}

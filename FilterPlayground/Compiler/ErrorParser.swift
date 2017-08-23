//
//  ErrorParser.swift
//  FilterPlayground
//
//  Created by Leo Thomas on 31.07.17.
//  Copyright © 2017 Leo Thomas. All rights reserved.
//

import Foundation

class ErrorParser {
    
    class func compileErrors(for errorString: String) -> [KernelError] {
        let components = errorString.components(separatedBy: "[CIKernelPool]").flatMap{ $0.firstLine }
        let errors = components.flatMap(getError)
        var result: [KernelError] = []
        for case .compile(lineNumber: let lineNumber, characterIndex: let characterIndex, type: let type, message: let message, note: let note) in errors {
            if type == "note" && result.count > 0 {
                if case .compile(lineNumber: let prevLineNumber, characterIndex: let prevCharacterIndex, type: let prevType, message: let prevMessage, note: _) = result[result.count-1] {
                    result[result.count-1] = .compile(lineNumber: prevLineNumber, characterIndex: prevCharacterIndex, type: prevType, message: prevMessage, note: (lineNumber, characterIndex, message))
                }
            } else {
                result.append(.compile(lineNumber: lineNumber, characterIndex: characterIndex, type: type, message: message, note: note))
            }
        }
        return result
    }
    
    fileprivate class func getError(for errorString: String) -> KernelError? {
        let components = errorString.components(separatedBy: ":").map{ $0.trimmingCharacters(in: CharacterSet.whitespaces) }
        guard components.count == 4 else { return nil }
        
        guard let lineNumber = Int(components[0]) else { return nil }
        guard let characterIndex = Int(components[1]) else { return nil }
        let type = components[2]
        let message = components[3]
        
        return .compile(lineNumber: lineNumber, characterIndex: characterIndex, type: type, message: message, note: nil)
    }
    
    class func runtimeErrors(for errorString: String) -> [KernelError] {
        return errorString.components(separatedBy: "[api]")[1...]
            .flatMap{ $0.firstLine }
            .flatMap{ $0.components(separatedBy: ":]").last }
            .flatMap{ $0.trimmingCharacters(in: .whitespaces) }
            .filter{ !$0.isEmpty }
            .flatMap{ .runtime(message: $0) }
    }
    
}

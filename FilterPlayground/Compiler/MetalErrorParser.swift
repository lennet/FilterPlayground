//
//  MetalErrorParser.swift
//  FilterPlayground
//
//  Created by Leo Thomas on 30.09.17.
//  Copyright © 2017 Leo Thomas. All rights reserved.
//

import Foundation

class MetalErrorParser  {
    
    class func compileErrors(for errorString: String) -> [KernelError] {
        let components = errorString.components(separatedBy: "program_source").flatMap { $0.firstLine }[1...]
        return components.flatMap(getError)
    }
    
    class func getError(errorString: String) -> KernelError? {
        let components = errorString.components(separatedBy: ":").map { $0.trimmingCharacters(in: CharacterSet.whitespaces) }
        guard components.count == 5 else { return nil }
        
        guard let lineNumber = Int(components[1]) else { return nil }
        guard let characterIndex = Int(components[2]) else { return nil }
        let typeString = components[3]
        let type = CompileErrorType(rawValue: typeString) ?? CompileErrorType.error
        let message = components[4]
        
        return .compile(lineNumber: lineNumber, characterIndex: characterIndex, type: type, message: message, note: nil)
    }
    
}

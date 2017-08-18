//
//  CompilerError.swift
//  FilterPlayground
//
//  Created by Leo Thomas on 04.08.17.
//  Copyright © 2017 Leo Thomas. All rights reserved.
//

import Foundation

struct CompilerError {
    var lineNumber: Int
    var characterIndex: Int
    var type: String
    var message: String
    var note: (Int, Int, String)?
}

extension CompilerError: Equatable {
    
    static func ==(lhs: CompilerError, rhs: CompilerError) -> Bool {
        return lhs.lineNumber == rhs.lineNumber &&
            lhs.characterIndex == rhs.characterIndex &&
            lhs.type == rhs.type &&
            lhs.message == rhs.message
    }
    
}

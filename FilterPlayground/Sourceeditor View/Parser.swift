//
//  Parser.swift
//  FilterPlayground
//
//  Created by Leo Thomas on 30.07.17.
//  Copyright © 2017 Leo Thomas. All rights reserved.
//

import Foundation

enum Token {
    case op(Operator)
    case float(value: Float)
    case whiteSpace
    case newLine
    case identifier(value: String)
    case none
}

extension Token: Equatable {
    
    static func ==(lhs: Token, rhs: Token) -> Bool {
        switch (lhs, rhs) {
        case (.none, .none):
            return true
        case (.op(let a), .op(let b)):
            return a == b
        case (.float(let a), .float(let b)):
            return a == b
        case (.whiteSpace, .whiteSpace):
            return true
        case (.newLine, .newLine):
            return true
        case (.identifier(let a), .identifier(let b)):
            return a == b
        default:
            return false
        }
    }
    
}

enum Operator:String, RawRepresentable {
    
    case add = "+"
    case minus = "-"
    case substract = "/"
    case multiply = "*"
    case assignment = "="
    
    var description: String {
        return rawValue
    }
}

class Tokenizer {
    
    var index: String.Index
    var string: String
    var isAtEnd: Bool {
        return index >= string.endIndex
    }
    
    init(string: String) {
        self.string = string
        index = string.startIndex
    }
    
    func getNextCharacter() -> String? {
        guard !isAtEnd else {
            return nil
        }
        
        let nextIndex = string.index(after: index)
        return String(string[index..<nextIndex])
    }
    
//    func getChracter(with distance: Int) -> String? {
//        let start = string.index(index, offsetBy: distance-1)
//        let end = string.index(index, offsetBy: distance)
//        return String(string[start..<end])
//    }
    
    func nextToken() -> Token? {
        guard let char = getNextCharacter() else { return nil }
        switch char {
        case "\n":
            index = string.index(after: index)
            return Token.newLine
        case " ":
            index = string.index(after: index)
            return Token.whiteSpace
        case let a where Operator(rawValue:a) != nil:
            index = string.index(after: index)
            return Token.op(Operator(rawValue:a)!)
        case let a where Float(a)?.isNormal ?? false :
            var floatString = a
            index = string.index(after: index)
            while let nextChar = getNextCharacter(),
                (Float(nextChar)?.isNaN ?? true) == false  || nextChar == "." {
                floatString.append(nextChar)
                index = string.index(after: index)
            }
    
            return Token.float(value: Float(floatString)!)
        case let a:
            var identifier = a
            
            index = string.index(after: index)
            while let nextChar = getNextCharacter(),
                CharacterSet.alphanumerics.contains(nextChar.unicodeScalars.first!) {
                    identifier.append(nextChar)
                    index = string.index(after: index)

            }
            
            return Token.identifier(value: identifier)
        default:
            // TODO
            break
        }
        
        return nil
    }
    
}

class Parser {
    
    let tokenizer: Tokenizer
    init(string: String) {
        tokenizer = Tokenizer(string: string)
    }
    
    func getTokens() -> [Token] {
                return []
    }
    
}

class Renderer {
    
    
}

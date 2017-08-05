//  Parser.swift
//  FilterPlayground
//
//  Created by Leo Thomas on 30.07.17.
//  Copyright © 2017 Leo Thomas. All rights reserved.
//

import Foundation
import UIKit

enum Token {
    case op(Operator)
    case float(String)
    case whiteSpace
    case newLine
    case tab
    case identifier(Identifier)
}

extension Token: Equatable {
    
    static func ==(lhs: Token, rhs: Token) -> Bool {
        switch (lhs, rhs) {
        case (.op(let a), .op(let b)):
            return a == b
        case (.float(let a), .float(let b)):
            return a == b
        case (.whiteSpace, .whiteSpace):
            return true
        case (.newLine, .newLine):
            return true
        case(.tab, .tab):
            return true
        case (.identifier(let a), .identifier(let b)):
            return a == b
        default:
            return false
        }
    }
    
}

extension Token {
    
    var stringRepresentation: String {
        switch self {
        case .op(let a):
            return a.rawValue
        case .whiteSpace:
            return " "
        case .newLine:
            return "\n"
        case .tab:
            return "\t"
        case .identifier(let a):
            return a.stringRepresentation
        case .float(let a):
            return a
        }
    }
    
    var attributes: [NSAttributedStringKey: Any] {
        switch self {
        case .float(_):
            return [NSAttributedStringKey.foregroundColor: ThemeManager.shared.currentTheme.sourceEditorTextFloat]
        case .identifier(let a):
            return a.attributes
        default:
            return [NSAttributedStringKey.foregroundColor: ThemeManager.shared.currentTheme.sourceEditorText]
        }
    }
    
}

enum Keyword: String {
    case kernel
    case kernelReturn = "return"
}

enum Identifier {
    case type(KernelAttributeType)
    case other(String)
    case keyword(Keyword)
    
    var attributes: [NSAttributedStringKey: Any] {
        let color: UIColor
        switch self {
        case .type(_):
            color = ThemeManager.shared.currentTheme.sourceEditorTextType
        case .keyword(_):
            color = ThemeManager.shared.currentTheme.sourceEditorTextKeyword
        default:
            color = ThemeManager.shared.currentTheme.sourceEditorText
        }
        return [NSAttributedStringKey.foregroundColor: color]
    }
    
}

extension Identifier: Equatable {
    
    static func ==(lhs: Identifier, rhs: Identifier) -> Bool {
        switch (lhs, rhs) {
        case (.other(let a), .other(let b)):
            return a == b
        case (.type(let a), .type(let b)):
            return a == b
        default:
            return false
        }
    }
    
    var stringRepresentation: String {
        switch self {
        case .other(let a):
            return a
        case .type(let a):
            return a.rawValue
        case .keyword(let a):
            return a.rawValue
        }
    }
    
    init(_ string: String) {
        if let keyword = Keyword(rawValue: string) {
            self = .keyword(keyword)
        } else if let type = KernelAttributeType(rawValue: string) {
            self = .type(type)
        } else {
            self = .other(string)
        }
    }
    
}

enum Operator: String {
    case add = "+"
    case minus = "-"
    case substract = "/"
    case multiply = "*"
    case assignment = "="
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
    
    func nextToken() -> Token? {
        guard let char = getNextCharacter() else { return nil }
        let oldIndex = index
        switch char {
        case "\n":
            
            index = string.index(after: index)
            return Token.newLine
        case " ":
            index = string.index(after: index)
            return Token.whiteSpace
        case "\t":
            index = string.index(after: index)
            return Token.tab
        case let a where Operator(rawValue:a) != nil:
            index = string.index(after: index)
            return Token.op(Operator(rawValue:a)!)
        case let a where !(Float(a)?.isNaN ?? true):
            var floatString = a
            var alreadyFoundDot = false
            index = string.index(after: index)
            while let nextChar = getNextCharacter(),
                (Float(nextChar)?.isNaN ?? true) == false  || (nextChar == "." && !alreadyFoundDot){
                    if (nextChar == ".") {
                        alreadyFoundDot =  true
                    }
                    floatString.append(nextChar)
                    index = string.index(after: index)
            }
            // todo refactor 
            if (getNextCharacter() ?? " ") == " " {
                return Token.float(floatString)
            } else {
                index = oldIndex
                return tokenizeIdentifer()
            }
        default:
            return tokenizeIdentifer()
        }
        
    }
    
    func tokenizeIdentifer() -> Token? {
        guard let nextChar = getNextCharacter() else { return nil }
        var identifier = nextChar
        index = string.index(after: index)
        while let nextChar = getNextCharacter(),
            // todo create own charactersets for identifier
            CharacterSet.alphanumerics.contains(nextChar.unicodeScalars.first!) || nextChar == "_" {
                identifier.append(nextChar)
                index = string.index(after: index)
        }
        
        return Token.identifier(Identifier(identifier))

    }
    
}

class Parser {
    
    let tokenizer: Tokenizer
    init(string: String) {
        tokenizer = Tokenizer(string: string)
    }
    
    func getTokens() -> [Token] {
        var tokens: [Token] = []
        while let token = tokenizer.nextToken() {
            tokens.append(token)
        }
        return tokens
    }
    
}

class Renderer {
    
    class func renderAsPlainText(tokens: [Token]) -> String {
        return tokens.map{ $0.stringRepresentation }.joined()
    }
    
    class func rederAsAttributedString(tokens: [Token]) -> NSAttributedString {
        return tokens.map{ NSAttributedString(string: $0.stringRepresentation, attributes: $0.attributes) }.reduce(NSAttributedString(), +)
    }
    
}

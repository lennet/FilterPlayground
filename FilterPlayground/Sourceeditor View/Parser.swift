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
    case semicolon
    case openingBracket
    case closingBracket
    case tab
    case identifier(Identifier)
}

extension Token: Equatable {

    static func ==(lhs: Token, rhs: Token) -> Bool {
        switch (lhs, rhs) {
        case let (.op(a), .op(b)):
            return a == b
        case let (.float(a), .float(b)):
            return a == b
        case (.whiteSpace, .whiteSpace),
             (.newLine, .newLine),
             (.tab, .tab),
             (.semicolon, .semicolon),
             (.openingBracket, .openingBracket),
             (.closingBracket, .closingBracket):
            return true
        case let (.identifier(a), .identifier(b)):
            return a == b
        default:
            return false
        }
    }
}

extension Token {

    var stringRepresentation: String {
        switch self {
        case let .op(a):
            return a.rawValue
        case .semicolon:
            return ";"
        case .whiteSpace:
            return " "
        case .newLine:
            return "\n"
        case .tab:
            return "\t"
        case let .identifier(a):
            return a.stringRepresentation
        case let .float(a):
            return a
        case .openingBracket:
            return "{"
        case .closingBracket:
            return "}"
        }
    }

    var attributes: [NSAttributedStringKey: Any] {
        switch self {
        case .float:
            return [NSAttributedStringKey.foregroundColor: ThemeManager.shared.currentTheme.sourceEditorTextFloat]
        case let .identifier(a):
            return a.attributes
        default:
            return [NSAttributedStringKey.foregroundColor: ThemeManager.shared.currentTheme.sourceEditorText]
        }
    }

    var isSpaceTabOrNewLine: Bool {
        return self == .whiteSpace || self == .newLine || self == .tab
    }
}

enum Keyword: String {
    case kernel
    case _if = "if"
    case _for = "for"
    case _do = "do"
    case _while = "while"
    case _return = "return"
}

enum Identifier {
    case type(KernelAttributeType)
    case other(String)
    case keyword(Keyword)

    var attributes: [NSAttributedStringKey: Any] {
        let color: UIColor
        switch self {
        case .type:
            color = ThemeManager.shared.currentTheme.sourceEditorTextType
        case .keyword:
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
        case let (.other(a), .other(b)):
            return a == b
        case let (.type(a), .type(b)):
            return a == b
        case let (.keyword(a), .keyword(b)):
            return a == b

        default:
            return false
        }
    }

    var stringRepresentation: String {
        switch self {
        case let .other(a):
            return a
        case let .type(a):
            return a.rawValue
        case let .keyword(a):
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
        return String(string[index ..< nextIndex])
    }

    func nextToken() -> Token? {
        guard let char = getNextCharacter() else { return nil }
        let oldIndex = index
        switch char {
        case Token.openingBracket.stringRepresentation:
            index = string.index(after: index)
            return Token.openingBracket
        case Token.closingBracket.stringRepresentation:
            index = string.index(after: index)
            return Token.closingBracket
        case Token.semicolon.stringRepresentation:
            index = string.index(after: index)
            return Token.semicolon
        case Token.newLine.stringRepresentation:
            index = string.index(after: index)
            return Token.newLine
        case " ":
            index = string.index(after: index)
            return Token.whiteSpace
        case Token.tab.stringRepresentation:
            index = string.index(after: index)
            return Token.tab
        case let a where Operator(rawValue: a) != nil:
            index = string.index(after: index)
            return Token.op(Operator(rawValue: a)!)
        case let a where !(CharacterSet.alphanumerics.contains(a.unicodeScalars.first!) || a == "_"):
            index = string.index(after: index)
            return Token.identifier(.other(a))
        case let a where !(Float(a)?.isNaN ?? true):
            var floatString = a
            var alreadyFoundDot = false
            index = string.index(after: index)
            while let nextChar = getNextCharacter(),
                (Float(nextChar)?.isNaN ?? true) == false || (nextChar == ".") {
                if nextChar == "." {
                    if alreadyFoundDot {
                        index = oldIndex
                        return tokenizeIdentifer()
                    } else {
                        alreadyFoundDot = true
                    }
                }
                floatString.append(nextChar)
                index = string.index(after: index)
            }
            return Token.float(floatString)
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

    func getAST() -> ASTNode {
        return ASTNode.root(ASTHelper.getAST(for: getTokens()))
    }
}

class Renderer {

    class func renderAsPlainText(tokens: [Token]) -> String {
        return tokens.map { $0.stringRepresentation }.joined()
    }

    class func rederAsAttributedString(tokens: [Token]) -> NSAttributedString {
        return tokens.map { NSAttributedString(string: $0.stringRepresentation, attributes: $0.attributes) }.reduce(NSAttributedString(), +)
    }
}

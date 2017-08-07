//
//  AST.swift
//  FilterPlayground
//
//  Created by Leo Thomas on 06.08.17.
//  Copyright © 2017 Leo Thomas. All rights reserved.
//

import Foundation

enum ASTNode {
    case unkown([Token])
    case comment(String)
    case statement([Token])
    case bracetStatement(prefix:[Token], body: [ASTNode], postfix: [Token])
    case root([ASTNode])
}

extension ASTNode: Equatable {
    
    static func ==(lhs: ASTNode, rhs: ASTNode) -> Bool {
        switch (lhs, rhs) {
        case (.comment(let left), .comment(let right)):
            return left == right
        case (.statement(let left), .statement(let right)):
            return left == right
        case (.bracetStatement(let leftPrefix, let leftBody, let leftPostFix), .bracetStatement(let rightPrefix, let rightBody, let rightPostfix)):
            return leftPrefix == rightPrefix && leftBody == rightBody && leftPostFix == rightPostfix
        case (.root(let left), .root(let right)):
            return left == right
        case (.unkown(let left), .unkown(let right)):
            return left == right
        default:
            return false
        }
    }
    
    var asAttributedText: NSAttributedString {
        switch self {
        case .bracetStatement(prefix: let prefix, body: let body, postfix: let postfix):
            let prefixValue = prefix.map{ NSAttributedString(string: $0.stringRepresentation, attributes: $0.attributes) }.reduce(NSAttributedString(), +)
            let bodyValue = body.map{$0.asAttributedText}.reduce(NSAttributedString(), +)
            let postFixValue = postfix.map{ NSAttributedString(string: $0.stringRepresentation, attributes: $0.attributes) }.reduce(NSAttributedString(), +)
            return prefixValue + bodyValue + postFixValue
        case .root(let nodes):
            return nodes.map{$0.asAttributedText}.reduce(NSAttributedString(), +)
        case .comment(let string):
            return NSAttributedString(string: string, attributes: [NSAttributedStringKey.foregroundColor: ThemeManager.shared.currentTheme.sourceEditTextComment])
        case .statement(let tokens),
             .unkown(let tokens):
            return tokens.map{ NSAttributedString(string: $0.stringRepresentation, attributes: $0.attributes) }.reduce(NSAttributedString(), +)
        }
    }
    
}

class ASTBuilder {
    
    private init() {}
    
    class func getAST(for tokens: [Token]) -> ([ASTNode]) {
        var nodes: [ASTNode] = []
        var lastNode = 0
        var i = 0
        while i < tokens.count {
            switch tokens[i] {
            case .op(.substract):
                if tokens.count > i && (tokens [i+1] == .op(.substract) || tokens [i+1] == .op(.multiply)) {
                    if lastNode != i {
                        nodes.append(.unkown(Array(tokens[lastNode..<i])))
                    }
                    let commentResult = buildComment(tokens: Array(tokens[i...]), multiLine: tokens [i+1] == .op(.multiply))
                    nodes.append(commentResult.0)
                    i = tokens.count - commentResult.1.count
                    lastNode = i
                }
                break
            case .semicolon:
                let node = ASTNode.statement(Array(tokens[lastNode...i]))
                nodes.append(node)
                lastNode = i + 1
                break
            case .openingBracket:
                let bodyResult = getAST(for: Array(tokens[(i+1)...]))
                let oldI = i
                
                if case let .unkown(content) = bodyResult.last ?? .unkown([]) {
                    i = tokens.count - content.count - 1
                } else {
                    i = tokens.count - 0 - 1
                }
                var postFix: [Token] = []
                if let closingBracketIndex = tokens.index(of: .closingBracket, after: i) {
                    postFix = [tokens[closingBracketIndex]]
                    i = closingBracketIndex + 1
                }
                
                let node = ASTNode.bracetStatement(prefix: Array(tokens[lastNode...oldI]), body: bodyResult, postfix: postFix)
                nodes.append(node)
                
                lastNode = i
                break
            case .closingBracket:
                if lastNode < i {
                    nodes.append(.unkown(Array(tokens[lastNode..<i])))
                }
                return (nodes)
            default:
                break
            }
            i += 1 
        }
        if lastNode < tokens.count {
            nodes.append(.unkown(Array(tokens[lastNode...])))
        }
        return nodes
    }
    
    class func buildComment(tokens: [Token], multiLine: Bool) -> (ASTNode, [Token]) {
        var comment: String = ""
        var tokenCount = 0
        for token in tokens {
            if token == Token.op(.multiply) && multiLine {
                
            } else if !multiLine && token == Token.newLine {
                break
            }
            comment += token.stringRepresentation
            tokenCount += 1
        }
        return (ASTNode.comment(comment), Array(tokens[tokenCount...]))
    }
    
}

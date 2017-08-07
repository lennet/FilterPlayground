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
    case comment([Token])
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
        case .comment(let tokens):
            let attributes =  [NSAttributedStringKey.foregroundColor: ThemeManager.shared.currentTheme.sourceEditTextComment]
            return tokens.map{ NSAttributedString(string: $0.stringRepresentation, attributes: attributes) }.reduce(NSAttributedString(), +)
        case .statement(let tokens),
             .unkown(let tokens):
            return tokens.map{ NSAttributedString(string: $0.stringRepresentation, attributes: $0.attributes) }.reduce(NSAttributedString(), +)
        }
    }
    
    var numberOfTokens: Int {
        switch self {
        case .bracetStatement(prefix: let prefix, body: let body, postfix: let postfix):
            return prefix.count + body.map{ $0.numberOfTokens }.reduce(0, +) + postfix.count
        case .root(let nodes):
            return nodes.map{$0.numberOfTokens}.reduce(0, +)
        case .statement(let tokens),
             .unkown(let tokens),
             .comment(let tokens):
            return tokens.count
        }
    }
    
    func intendationLevel(at index: Int, with depth: Int = 0) -> Int {
        switch self {
        case .bracetStatement(prefix: let prefix, body: let body, postfix:_):
            let bodyStartIndex = index - prefix.count
            let bodyRoot = ASTNode.root(body)
            if bodyStartIndex >= 0 && bodyStartIndex < bodyRoot.numberOfTokens {
                return bodyRoot.intendationLevel(at: bodyStartIndex, with: depth+1)
            }
            return depth 
        case .root(let nodes):
            var maxValue = depth
            var currentIndex = index
            nodes.forEach({ (node) in
                if currentIndex >= 0 && currentIndex < node.numberOfTokens {
                    maxValue = max(node.intendationLevel(at: currentIndex, with: depth), maxValue)
                }
                currentIndex -= node.numberOfTokens 
            })
            return maxValue
        case .statement(_),
        .unkown(_),
        .comment(_):
            return depth
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
                if i < tokens.count-1 && (tokens [i+1] == .op(.substract) || tokens [i+1] == .op(.multiply)) {
                    if lastNode != i {
                        nodes.append(.unkown(Array(tokens[lastNode..<i])))
                    }
                    let commentResult = buildComment(tokens: Array(tokens[i...]), multiLine: tokens [i+1] == .op(.multiply))
                    nodes.append(commentResult)
                    i += commentResult.numberOfTokens
                    lastNode = i
                }
                break
            case .semicolon:
                let node = ASTNode.statement(Array(tokens[lastNode...i]))
                nodes.append(node)
                lastNode = i + 1
                break
            case .openingBracket:
                let bodyTokens: [Token]
                if let lastIndex = Array(tokens.reversed()).index(of: .closingBracket) {
                    bodyTokens = Array(tokens[(i+1)..<(tokens.count-lastIndex)])
                } else {
                    bodyTokens = Array(tokens[(i+1)...])
                }
                let bodyResult = getAST(for: bodyTokens)
                let oldI = i
                
                i += bodyResult.map{ $0.numberOfTokens }.reduce(0, +)
                var postFix: [Token] = []
                if let closingBracketIndex = tokens.index(of: .closingBracket, after: i+1) {
                    postFix = [tokens[closingBracketIndex]]
                    i = closingBracketIndex + 1
                } else {
                    i += 1
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
    
    class func buildComment(tokens: [Token], multiLine: Bool) -> (ASTNode) {
        var resultIndex = 0
        for (index, token) in tokens.enumerated() {
            if !multiLine && token == Token.newLine {
                break
            }
            resultIndex = index
            if multiLine, index > 0 && token == .op(.substract) &&
                tokens[index-1] == .op(.multiply) {
                break
            }
        }
        return ASTNode.comment(Array(tokens[...resultIndex]))
    }
    
}

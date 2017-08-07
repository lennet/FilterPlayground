//
//  AST.swift
//  FilterPlayground
//
//  Created by Leo Thomas on 06.08.17.
//  Copyright © 2017 Leo Thomas. All rights reserved.
//

import Foundation

enum ASTNode {
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
        default:
            return false
        }
    }
    
    
}

struct AST {
    
    var root: ASTNode?
    
    init(with tokens: [Token]) {
        
        var unprocessedTokens: [Token] = []
        var currentBraceStatementPrefix: [Token] = []
        var unprocessedStatements: [ASTNode] = []
        
        for token in tokens {
            
            switch token {
            case .op(.substract):
                break
            case .semicolon:
                let node = ASTNode.statement(unprocessedTokens + [token])
                unprocessedStatements.append(node)
                break
            case .openingBracket:
                currentBraceStatementPrefix = unprocessedTokens + [token]
                unprocessedTokens = []
                break
            case .closingBracket:
                if currentBraceStatementPrefix.count > 0 {
                    let node = ASTNode.bracetStatement(prefix: currentBraceStatementPrefix, body: unprocessedStatements, postfix: [token])
                    unprocessedTokens = []
                    unprocessedStatements = [node]
                }
                break
            default:
                unprocessedTokens.append(token)
                break
            }
            
        }
        
    }
    
}

class ASTBuilder {
    
    private init() {}
    
    class func getAST(for tokens: [Token]) -> ([ASTNode], [Token]) {
        var nodes: [ASTNode] = []
        var lastNode = 0
        var i = 0
        while i < tokens.count {
            switch tokens[i] {
            case .op(.substract):
                if tokens.count > 1 && (tokens [1] == .op(.substract) || tokens [1] == .op(.multiply)) {
                    if lastNode != i {
                        // todo remove workaround for inline comments
                        let node = ASTNode.statement(Array(tokens[lastNode..<i]))
                        nodes.append(node)
                    }
                    let commentResult = buildComment(tokens: Array(tokens[i...]), multiLine: tokens [1] == .op(.multiply))
                    nodes.append(commentResult.0)
                    i = tokens.count - commentResult.1.count
                    lastNode = i
                }
                break
            case .semicolon:
                let node = ASTNode.statement(Array(tokens[lastNode...i]))
                nodes.append(node)
                lastNode = i
                break
            case .openingBracket:
                let bodyResult = getAST(for: Array(tokens[(i+1)...]))
                let oldI = i
//                i = tokens.count - bodyResult.1.count + lastNode - i
                i = tokens.count - bodyResult.1.count - 1
                var postFix: [Token] = []
                if let closingBracketIndex = tokens.index(of: .closingBracket, after: i) {
                    postFix = Array(tokens[i...closingBracketIndex])
                    i = closingBracketIndex + 1
                }
                let node = ASTNode.bracetStatement(prefix: Array(tokens[lastNode...oldI]), body: bodyResult.0, postfix: postFix)
                nodes.append(node)
                
                lastNode = i
                break
            case .closingBracket:
                return (nodes, Array(tokens[i...]))
            default:
                break
            }
            i += 1 
        }
        
        return(nodes, Array(tokens[lastNode...]))
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

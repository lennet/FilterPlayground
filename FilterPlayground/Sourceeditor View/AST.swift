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

typealias KernelDefinition = (name: String, returnType: KernelAttributeType, arguments: [(String,KernelAttributeType)])

func ==(lhs:(String,KernelAttributeType), rhs:(String,KernelAttributeType)) -> Bool {
    return lhs.0 == rhs.0 && lhs.1 == rhs.1
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
    
    func needsClosingBracket(at index: Int, openedBrackets: Int = 0) -> Bool {
        switch self {
        case .bracetStatement(prefix: let prefix, body: let body, postfix:let postFix):
            let bodyStartIndex = index - prefix.count
            let bodyRoot = ASTNode.root(body)
            let hasClosingBracket = postFix.contains(.closingBracket)
            if bodyStartIndex >= 0 && bodyStartIndex < bodyRoot.numberOfTokens {
                return bodyRoot.needsClosingBracket(at: bodyStartIndex, openedBrackets: openedBrackets + (hasClosingBracket ? 0: 1))
            }
            return !hasClosingBracket
        case .root(let nodes):
            var currentIndex = index
            for node in nodes {
                if currentIndex >= 0 && currentIndex < node.numberOfTokens {
                    return node.needsClosingBracket(at: currentIndex, openedBrackets: openedBrackets)
                }
                currentIndex -= node.numberOfTokens
            }
            return false
        case .statement(_),
             .unkown(_),
             .comment(_):
            return openedBrackets > 0
        }
    }
    
    func kernelDefinition() -> KernelDefinition? {
        guard case .root(let nodes) = self else {
            return nil
        }
        
        for case .bracetStatement(prefix: let prefix, body: _, postfix: _) in nodes {
            let tokens = prefix
                .filter {
                    if case .identifier(_) = $0 {
                        return true
                    }
                    return false
            }
            guard tokens.count >= 4 else { continue }
            switch (tokens[0], tokens[1], tokens[2], tokens[3]) {
            case (.identifier(.keyword(.kernel)), .identifier(.type(let type)), .identifier(.other(let name)), .identifier(.other("("))):
                return (name: name, returnType: type, arguments:ASTHelper.arguments(for: Array(tokens[3...])))
            default:
                continue
            }
        }
        
        return nil
    }
    
    func astWithReplacedArguments(newArguments: [(String, KernelAttributeType)]) -> ASTNode? {
        guard case .root(let nodes) = self else {
            return nil
        }
    
        var otherNodes: [ASTNode] = []
        
        for (index, node) in nodes.enumerated() {
            guard case .bracetStatement(prefix: let prefix, body: let body, postfix: let postfix) = node else {
                otherNodes.append(node)
                continue
            }
            let kernelIndex = prefix.index(of: .identifier(.keyword(.kernel)))
            let tokens = prefix
                .filter {
                    if case .identifier(_) = $0 {
                        return true
                    }
                    return false
            }
            guard tokens.count >= 4 else {
                otherNodes.append(node)
                continue
                
            }
            switch (tokens[0], tokens[1], tokens[2], tokens[3]) {
            case (.identifier(.keyword(.kernel)), .identifier(.type(_)), .identifier(.other(_)), .identifier(.other("("))):
                let argumentsToken = newArguments
                    .map{[Token.identifier(.type($0.1)), Token.whiteSpace, Token.identifier(.other($0.0))]}
                    .joined(separator: [Token.identifier(.other(",")), Token.whiteSpace])
                var newPrefix: [Token] = [tokens[0], .whiteSpace, tokens[1], .whiteSpace, tokens[2], tokens[3]]
                    + argumentsToken
                    + [.identifier(.other(")")), .whiteSpace, .openingBracket]
                
                if let kernelIndex = kernelIndex,
                    kernelIndex > 0 {
                    newPrefix = prefix[0..<kernelIndex] + newPrefix
                }

                let newRoot = ASTNode.bracetStatement(prefix: newPrefix, body: body, postfix: postfix)
                
                let nodes = [otherNodes, [newRoot], Array(nodes[(index+1)...])]
                    .filter{ !$0.isEmpty}
                    .reduce([], +)
                return .root(nodes)
            default:
                otherNodes.append(node)
                continue
            }
        }
        
        return nil
    }
    
}

class ASTHelper {
    
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
                
                if let lastIndex = tokens.indexCountingFromLastElement(of: .closingBracket),
                    tokens.count > (i + 1),
                    (i+1) < lastIndex {
                    bodyTokens = Array(tokens[(i+1)..<lastIndex])
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
    
    class func arguments(for tokens: [Token]) -> [(String, KernelAttributeType)] {
        var result: [(String, KernelAttributeType)] = []
        let filtred = tokens.filter{ token in
            switch token {
            case .identifier(.other(")")),
                 .identifier(.other("(")):
                return false
            default:
                return true
            }
        }
        for component in filtred.split(separator: .identifier(.other(","))) where component.count == 2 {
            if case Token.identifier(.type(let type)) = component.first!,
                case Token.identifier(.other(let name)) = component.last! {
                result.append((name, type))
            }
        }
        return result
    }
    
}

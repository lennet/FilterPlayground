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
    case bracetStatement(prefix: [Token], body: [ASTNode], postfix: [Token])
    case root([ASTNode])
}

func == (lhs: (String, KernelArgumentType), rhs: (String, KernelArgumentType)) -> Bool {
    return lhs.0 == rhs.0 && lhs.1 == rhs.1
}

extension ASTNode: Equatable {

    static func == (lhs: ASTNode, rhs: ASTNode) -> Bool {
        switch (lhs, rhs) {
        case let (.comment(left), .comment(right)):
            return left == right
        case let (.statement(left), .statement(right)):
            return left == right
        case let (.bracetStatement(leftPrefix, leftBody, leftPostFix), .bracetStatement(rightPrefix, rightBody, rightPostfix)):
            return leftPrefix == rightPrefix && leftBody == rightBody && leftPostFix == rightPostfix
        case let (.root(left), .root(right)):
            return left == right
        case let (.unkown(left), .unkown(right)):
            return left == right
        default:
            return false
        }
    }

    var asAttributedText: NSAttributedString {
        switch self {
        case let .bracetStatement(prefix: prefix, body: body, postfix: postfix):
            let prefixValue = prefix.map { NSAttributedString(string: $0.stringRepresentation, attributes: $0.attributes) }.reduce(NSAttributedString(), +)
            let bodyValue = body.map { $0.asAttributedText }.reduce(NSAttributedString(), +)
            let postFixValue = postfix.map { NSAttributedString(string: $0.stringRepresentation, attributes: $0.attributes) }.reduce(NSAttributedString(), +)
            return prefixValue + bodyValue + postFixValue
        case let .root(nodes):
            return nodes.map { $0.asAttributedText }.reduce(NSAttributedString(), +)
        case let .comment(tokens):
            let attributes = [NSAttributedStringKey.foregroundColor: ThemeManager.shared.currentTheme.sourceEditTextComment]
            return tokens.map { NSAttributedString(string: $0.stringRepresentation, attributes: attributes) }.reduce(NSAttributedString(), +)
        case let .statement(tokens),
             let .unkown(tokens):
            return tokens.map { NSAttributedString(string: $0.stringRepresentation, attributes: $0.attributes) }.reduce(NSAttributedString(), +)
        }
    }

    var tokens: [Token] {
        switch self {
        case let .bracetStatement(prefix: prefix, body: body, postfix: postfix):
            return prefix
                + body
                .map { $0.tokens }
                .reduce([Token](), +)
                + postfix
        case let .root(nodes):
            return nodes
                .map { $0.tokens }
                .reduce([Token](), +)
        case let .statement(tokens),
             let .unkown(tokens),
             let .comment(tokens):
            return tokens
        }
    }

    var numberOfTokens: Int {
        return tokens.count
    }

    func intendationLevel(at index: Int, with depth: Int = 0) -> Int {
        switch self {
        case .bracetStatement(prefix: let prefix, body: let body, postfix: _):
            let bodyStartIndex = index - prefix.count
            let bodyRoot = ASTNode.root(body)
            if bodyStartIndex >= 0 && bodyStartIndex < bodyRoot.numberOfTokens {
                return bodyRoot.intendationLevel(at: bodyStartIndex, with: depth + 1)
            }
            return depth
        case let .root(nodes):
            var maxValue = depth
            var currentIndex = index
            nodes.forEach({ node in
                if currentIndex >= 0 && currentIndex < node.numberOfTokens {
                    maxValue = max(node.intendationLevel(at: currentIndex, with: depth), maxValue)
                }
                currentIndex -= node.numberOfTokens
            })
            return maxValue
        case .statement(_),
             .unkown(_),
             .comment:
            return depth
        }
    }

    func needsClosingBracket(at index: Int, openedBrackets: Int = 0) -> Bool {
        switch self {
        case let .bracetStatement(prefix: prefix, body: body, postfix: postFix):
            let bodyStartIndex = index - prefix.count
            let bodyRoot = ASTNode.root(body)
            let hasClosingBracket = postFix.contains(.closingBracket)
            if bodyStartIndex >= 0 && bodyStartIndex < bodyRoot.numberOfTokens {
                return bodyRoot.needsClosingBracket(at: bodyStartIndex, openedBrackets: openedBrackets + (hasClosingBracket ? 0 : 1))
            }
            return !hasClosingBracket
        case let .root(nodes):
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
             .comment:
            return openedBrackets > 0
        }
    }

    func kernelDefinition() -> KernelDefinition? {
        guard case let .root(nodes) = self else {
            return nil
        }

        for case .bracetStatement(prefix: let prefix, body: _, postfix: _) in nodes {
            let tokens = prefix
                .filter {
                    if case .identifier = $0 {
                        return true
                    }
                    return false
                }
            guard tokens.count >= 4 else { continue }
            switch (tokens[0], tokens[1], tokens[2], tokens[3]) {
            case let (.identifier(.keyword(.kernel)), .identifier(.type(type)), .identifier(.other(name)), .identifier(.other("("))):
                return KernelDefinition(name: name, returnType: type, arguments: ASTHelper.arguments(for: Array(tokens[3...])))
            default:
                continue
            }
        }

        return nil
    }

    mutating func replaceArguments(newArguments: [KernelDefinitionArgument]) {
        switch self {
        case .unkown(_),
             .comment(_),
             .statement:
            return
        case .bracetStatement(prefix: var prefix, body: let body, postfix: let postfix):
            let kernelIndex = prefix.index(of: .identifier(.keyword(.kernel)))
            let tokens = prefix
                .filter {
                    if case .identifier = $0 {
                        return true
                    }
                    return false
                }
            guard tokens.count >= 4 else {
                return
            }
            switch (tokens[0], tokens[1], tokens[2], tokens[3]) {
            case (.identifier(.keyword(.kernel)), .identifier(.type(_)), .identifier(.other(_)), .identifier(.other("("))):
                let argumentsToken = newArguments
                    .map { [Token.identifier(.type($0.type)), Token.whiteSpace, Token.identifier(.other($0.name))] }
                    .joined(separator: [Token.identifier(.other(",")), Token.whiteSpace])
                var newPrefix: [Token] = [tokens[0], .whiteSpace, tokens[1], .whiteSpace, tokens[2], tokens[3]]
                    + argumentsToken
                    + [.identifier(.other(")")), .whiteSpace, .openingBracket]

                if let kernelIndex = kernelIndex,
                    kernelIndex > 0 {
                    newPrefix = prefix[0 ..< kernelIndex] + newPrefix
                }

                self = .bracetStatement(prefix: newPrefix, body: body, postfix: postfix)
                return
            default:
                return
            }
        case let .root(nodes):
            self = .root(nodes.map {
                var tmp = $0
                tmp.replaceArguments(newArguments: newArguments)
                return tmp
            })
            return
        }
    }

    mutating func replace(token: Token, with replacement: Token) {
        switch self {
        case var .unkown(tokens):
            tokens.replace(element: token, with: replacement)
            self = .unkown(tokens)
            break
        case var .comment(tokens):
            tokens.replace(element: token, with: replacement)
            self = .comment(tokens)
            break
        case var .statement(tokens):
            tokens.replace(element: token, with: replacement)
            self = .statement(tokens)
            break
        case var .bracetStatement(prefix: prefixToken, body: bodyNodes, postfix: postFixToken):
            prefixToken.replace(element: token, with: replacement)
            postFixToken.replace(element: token, with: replacement)
            bodyNodes = bodyNodes.map {
                var tmp = $0
                tmp.replace(token: token, with: replacement)
                return tmp
            }
            self = .bracetStatement(prefix: prefixToken, body: bodyNodes, postfix: postFixToken)
            break
        case var .root(nodes):
            nodes = nodes.map {
                var tmp = $0
                tmp.replace(token: token, with: replacement)
                return tmp
            }
            self = .root(nodes)
            break
        }
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
                if i < tokens.count - 1 && (tokens[i + 1] == .op(.substract) || tokens[i + 1] == .op(.multiply)) {
                    if lastNode != i {
                        nodes.append(.unkown(Array(tokens[lastNode ..< i])))
                    }
                    let commentResult = buildComment(tokens: Array(tokens[i...]), multiLine: tokens[i + 1] == .op(.multiply))
                    nodes.append(commentResult)
                    i += commentResult.numberOfTokens
                    lastNode = i
                }
                break
            case .semicolon:
                let node = ASTNode.statement(Array(tokens[lastNode ... i]))
                nodes.append(node)
                lastNode = i + 1
                break
            case .openingBracket:
                let bodyTokens: [Token]

                if let lastIndex = tokens.indexCountingFromLastElement(of: .closingBracket),
                    tokens.count > (i + 1),
                    (i + 1) < lastIndex {
                    bodyTokens = Array(tokens[(i + 1) ..< lastIndex])
                } else {
                    bodyTokens = Array(tokens[(i + 1)...])
                }
                let bodyResult = getAST(for: bodyTokens)
                let oldI = i

                i += bodyResult.map { $0.numberOfTokens }.reduce(0, +)
                var postFix: [Token] = []
                if let closingBracketIndex = tokens.index(of: .closingBracket, after: i + 1) {
                    postFix = [tokens[closingBracketIndex]]
                    i = closingBracketIndex + 1
                } else {
                    i += 1
                }

                let node = ASTNode.bracetStatement(prefix: Array(tokens[lastNode ... oldI]), body: bodyResult, postfix: postFix)
                nodes.append(node)

                lastNode = i
                break
            case .closingBracket:
                if lastNode < i {
                    nodes.append(.unkown(Array(tokens[lastNode ..< i])))
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

    class func buildComment(tokens: [Token], multiLine: Bool) -> ASTNode {
        var resultIndex = 0
        for (index, token) in tokens.enumerated() {
            if !multiLine && token == Token.newLine {
                break
            }
            resultIndex = index
            if multiLine, index > 0 && token == .op(.substract) &&
                tokens[index - 1] == .op(.multiply) {
                break
            }
        }
        return ASTNode.comment(Array(tokens[...resultIndex]))
    }

    class func arguments(for tokens: [Token]) -> [KernelDefinitionArgument] {
        var result: [KernelDefinitionArgument] = []
        let filtred = tokens.filter { token in
            switch token {
            case .identifier(.other(")")),
                 .identifier(.other("(")):
                return false
            default:
                return true
            }
        }
        for component in filtred.split(separator: .identifier(.other(","))) where component.count == 2 {
            if case let Token.identifier(.type(type)) = component.first!,
                case let Token.identifier(.other(name)) = component.last! {
                result.append(KernelDefinitionArgument(name: name, type: type))
            }
        }
        return result
    }
}

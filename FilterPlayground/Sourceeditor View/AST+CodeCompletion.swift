//
//  AST+CodeCompletion.swift
//  FilterPlayground
//
//  Created by Leo Thomas on 25.09.17.
//  Copyright © 2017 Leo Thomas. All rights reserved.
//

import Foundation

extension ASTNode {
    var functionName: String? {
        if let kernelDefinition = ASTNode.root([self]).kernelDefinition() {
            return kernelDefinition.name
        }

        if case .bracetStatement(prefix: let prefix, body: _, postfix: _) = self {
            let tokens = prefix
                .filter {
                    if case .identifier = $0 {
                        return true
                    }
                    return false
                }
            guard tokens.count >= 3 else { return nil }
            switch (tokens[0], tokens[1], tokens[2]) {
            case let (.identifier(.type(_)), .identifier(.other(name)), .identifier(.other("("))):
                return name
            default:
                return nil
            }
        }

        return nil
    }

    func isInsideBody(at index: Int) -> Bool {
        switch self {
        case .bracetStatement(prefix: let prefix, body: let body, postfix: _):
            var result: [String] = []

            if let kernelDefinition = ASTNode.root([self]).kernelDefinition() {
                result.append(contentsOf: kernelDefinition.arguments.map { $0.name })
            }

            let bodyStartIndex = index - prefix.count
            let bodyRoot = ASTNode.root(body)

            if bodyStartIndex >= 0 && bodyStartIndex < bodyRoot.numberOfTokens {
                return true
            }
            return false
        case let .root(nodes):
            var currentIndex = index
            var result = false
            nodes.forEach({ node in
                if currentIndex >= 0 && currentIndex <= node.numberOfTokens {
                    result = node.isInsideBody(at: currentIndex)
                    return
                }
                currentIndex -= node.numberOfTokens
            })
            return result
        case .statement(_),
             .comment(_),
             .unkown:
            return false
        }
    }

    func codeCompletion(at index: Int, with functions: [String] = [], variables: [String] = []) -> [String] {
        switch self {
        case .bracetStatement(prefix: let prefix, body: let body, postfix: _):
            var result: [String] = []

            if let kernelDefinition = ASTNode.root([self]).kernelDefinition() {
                result.append(contentsOf: kernelDefinition.arguments.map { $0.name })
            }

            let containsReturn = body.compactMap { $0.tokens.contains(.identifier(.keyword(._return))) ? true : nil }.count > 0
            if !containsReturn {
                result.append(Token.identifier(.keyword(._return)).stringRepresentation + " ")
            }

            let bodyStartIndex = index - prefix.count
            let bodyRoot = ASTNode.root(body)

            if bodyStartIndex >= 0 && bodyStartIndex < bodyRoot.numberOfTokens {
                result.append(contentsOf: bodyRoot.codeCompletion(at: bodyStartIndex, with: functions))
            }
            return result
        case let .root(nodes):
            var currentIndex = index
            var result: [String] = []
            var functionNames: [String] = []
            nodes.forEach({ node in
                if currentIndex >= 0 && currentIndex <= node.numberOfTokens {
                    result.append(contentsOf: node.codeCompletion(at: currentIndex, with: functionNames + functions))
                }
                if let functionName = node.functionName {
                    functionNames.append(functionName)
                }
                currentIndex -= node.numberOfTokens
            })
            let allTokens = self.tokens

            let previousToken = allTokens.count > 0 && index > 0 ? allTokens[index - 1] : nil
            var currentSelectedText: String = ""
            if let previousToken = previousToken {
                currentSelectedText = previousToken.stringRepresentation
            }
            return result.filter({ (candidate) -> Bool in
                (currentSelectedText == "" || candidate.contains(currentSelectedText) || currentSelectedText.rangeOfCharacter(from: CharacterSet.letters.inverted) != nil)
            })
        case .statement:
            return variables + functions
        case .comment:
            return []
        case let .unkown(tokens):
            let filtredToken = tokens.filter({ (token) -> Bool in
                !token.isSpaceTabOrNewLine
            })
            guard let last = filtredToken.last else {
                return KernelArgumentType.all.map { $0.rawValue }
            }
            switch last {
            case .identifier(.other(")")),
                 .float:
                return [";"]
            case .identifier(.other("=")),
                 .identifier(.keyword(._return)):
                return functions + variables
            default:
                return functions + variables
            }
        }
    }
}

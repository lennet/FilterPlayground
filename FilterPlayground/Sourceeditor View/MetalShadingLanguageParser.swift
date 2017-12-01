//
//  MetalShadingLanguageParser.swift
//  FilterPlayground
//
//  Created by Leo Thomas on 30.11.17.
//  Copyright © 2017 Leo Thomas. All rights reserved.
//

import Foundation

class MetalShadingLanguageParser {

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

    func getKernelDefinition() -> KernelDefinition? {
        // TODO: check compiler
        let tokens = getTokens()
        guard let kernelIndex = tokens.indexCountingFromLastElement(of: .identifier(.keyword(.kernel))) else {
            return nil
        }
        let tokensAfterKernelDefinition = tokens[kernelIndex...]
            .filter { (token) -> Bool in
                return !token.isSpaceTabOrNewLine
            }

        guard case .identifier(.type(.void)) = tokensAfterKernelDefinition[1] else {
            return nil
        }
        guard case let .identifier(.other(name)) = tokensAfterKernelDefinition[2] else {
            return nil
        }

        guard case let .identifier(.other(openinigBracket)) = tokensAfterKernelDefinition[3],
            openinigBracket == "("else {
            return nil
        }

        var openedBrackedCount = 1
        var closingIndex = -1
        for (index, token) in tokensAfterKernelDefinition[4...].enumerated() {
            switch token {
            case .identifier(.other("(")):
                openedBrackedCount += 1
                break
            case .identifier(.other(")")):
                openedBrackedCount -= 1
                break
            default:
                break
            }
            if openedBrackedCount == 0 {
                closingIndex = index
                break
            }
        }
        guard closingIndex != -1 else {
            return nil
        }

        let argumentTokenArrays = Array(tokensAfterKernelDefinition[4 ... closingIndex]).split(separators: .identifier(.other("]")), .identifier(.other(",")))
        let arguments = argumentTokenArrays.flatMap(argument)
        return KernelDefinition(name: name, returnType: .void, arguments: arguments)
    }

    func argument(for tokens: [Token]) -> KernelDefinitionArgument? {
        var unprocessedTokens = tokens
        guard case let .identifier(.type(type)) = unprocessedTokens.removeFirst() else {
            return nil
        }
        var next = unprocessedTokens.removeFirst()
        var access: KernelArgumentAccess = .na
        if case .identifier(.other("<")) = next {
            // get access if available
            guard let closingIndex = unprocessedTokens.index(of: .identifier(.other(">"))) else {
                return nil
            }
            guard case let .identifier(.other(accessType)) = Array(unprocessedTokens[...closingIndex]).split(separators: .identifier(.other("access")), .identifier(.other(":")), .identifier(.other(":"))).last!.first! else {
                return nil
            }
            access = KernelArgumentAccess(rawValue: accessType) ?? .na
            unprocessedTokens.removeFirst(closingIndex + 1)
            next = unprocessedTokens.removeFirst()
        }
        guard case let .identifier(.other(name)) = next else {
            return nil
        }

        return KernelDefinitionArgument(name: name, type: type, access: access)
    }

    func textWithInserted(arguments _: [KernelDefinitionArgument]) -> String {
        return ""
    }
}

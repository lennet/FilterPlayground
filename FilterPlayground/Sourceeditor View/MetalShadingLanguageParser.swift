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

    func getKernelDefinition() -> KernelDefinition? {
        let tokens = tokenizer.getTokens()
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

        let argumentTokenArrays = Array(tokensAfterKernelDefinition[4 ... closingIndex + 1]).split(separators: .identifier(.other("]")), .identifier(.other(",")))
        let arguments = argumentTokenArrays.flatMap(argument)
        return KernelDefinition(name: name, returnType: .void, arguments: arguments)
    }

    func argument(for tokens: [Token]) -> KernelDefinitionArgument? {
        var unprocessedTokens = tokens
        var access: KernelArgumentAccess = .na

        var first = unprocessedTokens.removeFirst()
        if case .identifier(.other("constant")) = first {
            access = .constant
            first = unprocessedTokens.removeFirst()
        }
        guard case let .identifier(.type(type)) = first else {
            return nil
        }
        var next = unprocessedTokens.removeFirst()

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

        let originIndex = (unprocessedTokens.indexCountingFromLastElement(of: .identifier(.other("["))) ?? 0) + 1
        let origin: KernelArgumentOrigin
        switch unprocessedTokens[originIndex] {
        case .identifier(.other("buffer")):
            origin = .buffer
            break
        case .identifier(.other("texture")):
            origin = .texture
            break
        case let .identifier(.other(value)):
            origin = .other(value)
            break
        default:
            fatalError("not supported origin")
        }

        return KernelDefinitionArgument(name: name, type: type, access: access, origin: origin)
    }

    func textWithInserted(arguments: [KernelDefinitionArgument]) -> String? {
        var tokens = tokenizer.getTokens()

        guard let kernelIndex = tokens.indexCountingFromLastElement(of: .identifier(.keyword(.kernel))) else {
            return nil
        }

        guard let openingBracketIndex = tokens.index(of: .openingBracket, after: kernelIndex) else {
            return nil
        }

        guard let startKernelArgumentDefinitionIndex = tokens.index(of: .identifier(.other("(")), after: kernelIndex) else {
            return nil
        }

        guard let endKernelArgumentDefinitionIndex = tokens.indexCounting(from: openingBracketIndex, of: .identifier(.other(")"))) else {
            return nil
        }

        let newTokens = Tokenizer(string: kernelArgumentDefinitionString(for: arguments)).getTokens()

        if endKernelArgumentDefinitionIndex - startKernelArgumentDefinitionIndex > 1 {
            tokens.replaceSubrange(startKernelArgumentDefinitionIndex + 1 ... endKernelArgumentDefinitionIndex - 1, with: newTokens)
        } else {
            tokens.insert(contentsOf: newTokens, at: startKernelArgumentDefinitionIndex + 1)
        }

        return Renderer.renderAsPlainText(tokens: tokens)
    }

    func kernelArgumentDefinitionString(for arguments: [KernelDefinitionArgument]) -> String {
        var bufferIndex = 0
        var textureIndex = 0
        return arguments.map { (argument) -> String in
            let originString: String
            switch argument.origin {
            case .buffer:
                originString = "[[texture(\(bufferIndex)]]"
                bufferIndex += 1
            case let .other(value):
                originString = "[\(value)]"
            case .texture:
                originString = "[[texture(\(textureIndex)]]"
                textureIndex += 1
            case .na:
                fatalError("not supported origin")
            }

            switch (argument.type, argument.access) {
            case (.texture2d, .read):
                return "\(argument.type)<float, access::read> \(argument.name) \(originString)"
            case (.texture2d, .write):
                return "\(argument.type)<float, access::write> \(argument.name) \(originString)"
            case (_, .constant):
                return "constant \(argument.type) \(argument.name) \(originString)"
            case (_, .na):
                return "\(argument.type) \(argument.name) \(originString)"
            default:
                fatalError("not supported type access combination")
            }
        }.joined(separator: ", ")
    }
}

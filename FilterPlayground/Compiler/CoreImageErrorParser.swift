//
//  CoreImageErrorParser.swift
//  FilterPlayground
//
//  Created by Leo Thomas on 31.07.17.
//  Copyright © 2017 Leo Thomas. All rights reserved.
//

import Foundation

class CoreImageErrorParser {
    class func compileErrors(for errorString: String) -> [KernelError] {
        let components = errorString.components(separatedBy: "[CIKernelPool]").compactMap { $0.firstLine }
        let errors = components.compactMap(getError)
        var result: [KernelError] = []
        for case let .compile(lineNumber: lineNumber, characterIndex: characterIndex, type: type, message: message, note: note) in errors {
            if type == .note && result.count > 0 {
                if case .compile(lineNumber: let prevLineNumber, characterIndex: let prevCharacterIndex, type: let prevType, message: let prevMessage, note: _) = result[result.count - 1] {
                    result[result.count - 1] = .compile(lineNumber: prevLineNumber, characterIndex: prevCharacterIndex, type: prevType, message: prevMessage, note: (lineNumber, characterIndex, message))
                }
            } else {
                result.append(.compile(lineNumber: lineNumber, characterIndex: characterIndex, type: type, message: message, note: note))
            }
        }
        let unkownErrors = unkownCompileError(for: errorString)
        if result.isEmpty && !unkownErrors.isEmpty {
            result.append(contentsOf: unkownErrors)
        }
        return result
    }

    fileprivate class func getError(for errorString: String) -> KernelError? {
        let components = errorString.components(separatedBy: ":").map { $0.trimmingCharacters(in: CharacterSet.whitespaces) }
        guard components.count >= 4,
            let lineNumber = Int(components[0]),
            let characterIndex = Int(components[1]) else { return unkownCompileError(for: errorString).first }

        let typeString = components[2]
        let type = CompileErrorType(rawValue: typeString) ?? .error
        let message = components[3...].joined(separator: ": ")

        return .compile(lineNumber: lineNumber, characterIndex: characterIndex, type: type, message: message, note: nil)
    }

    class func runtimeErrors(for errorString: String) -> [KernelError] {
        return errorString.components(separatedBy: "[api]")[1...]
            .compactMap { $0.firstLine }
            .compactMap { $0.components(separatedBy: ":]").last }
            .compactMap { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }
            .compactMap { .runtime(message: $0) }
    }

    class func unkownCompileError(for errorString: String) -> [KernelError] {
        return errorString.components(separatedBy: "[compile]")[1...]
            .compactMap { $0.firstLine }
            .compactMap { $0.components(separatedBy: ":]").last }
            .compactMap { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }
            .compactMap { KernelError.compile(lineNumber: -1, characterIndex: -1, type: .error, message: $0, note: nil) }
    }
}

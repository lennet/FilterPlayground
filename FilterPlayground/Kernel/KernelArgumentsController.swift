//
//  KernelArgumentsController.swift
//  FilterPlayground
//
//  Created by Leo Thomas on 02.04.18.
//  Copyright © 2018 Leo Thomas. All rights reserved.
//

import AVFoundation
import Foundation

enum KernelUIUpdate: Equatable {
    case insertion(Int)
    case deletion(Int)
    case update(Int, KernelArgument)
    case reload(Int)

    static func == (lhs: KernelUIUpdate, rhs: KernelUIUpdate) -> Bool {
        switch (lhs, rhs) {
        case let (.insertion(lhsRow), .insertion(rhsRow)), let (.deletion(lhsRow), .deletion(rhsRow)), let (.update(lhsRow, _), .update(rhsRow, _)), let (.reload(lhsRow), .reload(rhsRow)):
            return lhsRow == rhsRow
        default:
            return false
        }
    }

    var row: Int {
        switch self {
        case let .insertion(row), let .deletion(row), let .update(row, _), let .reload(row):
            return row
        }
    }
}

enum KernelArgumentSource: Equatable {
    static func == (lhs: KernelArgumentSource, rhs: KernelArgumentSource) -> Bool {
        switch (lhs, rhs) {
        case (.code, .code), (.render, .render):
            return true
        case let (.ui(lhsUpdates), .ui(rhsUpdates)):
            return lhsUpdates == rhsUpdates
        default:
            return false
        }
    }

    case code
    case ui([KernelUIUpdate])
    case render
}

class KernelArgumentsController {
    var currentArguments: [KernelArgument] {
        get {
            return kernel.arguments
        }
        set {
            kernel.arguments = newValue
        }
    }

    var cachedUIUpdates: [KernelUIUpdate] = []

    var shouldUpdateCallback: (KernelArgumentSource) -> Void
    var kernel: Kernel
    var databindingObservers: [GenericDatabindingObserver]

    init(kernel: Kernel, shouldUpdateCallback: @escaping (KernelArgumentSource) -> Void) {
        self.shouldUpdateCallback = shouldUpdateCallback
        self.kernel = kernel
        databindingObservers = []

        #if os(iOS) || os(tvOS)
            let displayLink = CADisplayLink(target: self, selector: #selector(updateUIIfNeeded))
            displayLink.preferredFramesPerSecond = 5
            displayLink.add(to: .current, forMode: .defaultRunLoopMode)
        #endif
    }

    func updateArgumentsFromCode(arguments: [KernelDefinitionArgument]) {
        var hasChanged = arguments.count != currentArguments.count
        var kernelUIUpdates: [KernelUIUpdate] = []
        let newArguments = arguments.enumerated().map { (index, argument) -> KernelArgument in
            if index < currentArguments.count {
                var currentArgument = currentArguments[index]
                if currentArgument.type == argument.type {
                    if currentArgument.name != argument.name {
                        currentArgument.name = argument.name
                        kernelUIUpdates.append(.update(currentArgument.index, currentArgument))
                        hasChanged = true
                    }
                    return currentArgument
                }
            }
            hasChanged = true
            kernelUIUpdates.append(.reload(argument.index))
            return KernelArgument(index: argument.index, name: argument.name, type: argument.type, value: argument.type.defaultValue, access: argument.access, origin: argument.origin)
        }
        if hasChanged {
            currentArguments = newArguments
            shouldUpdateCallback(.ui(kernelUIUpdates))
            updateDatabindingObservers()
        }
    }

    func updateArgumentsFromUI(arguments: [KernelArgument]) {
        var argumentsHaveChanged = arguments.count != currentArguments.count
        var onlyValuesChanged = arguments.count == currentArguments.count
        var shouldUpdateObservers = false
        let newArguments = arguments.enumerated().map { (index, argument) -> KernelArgument in
            if index < currentArguments.count {
                var currentArgument = currentArguments[index]

                if currentArgument.name != argument.name {
                    currentArgument.name = argument.name
                    onlyValuesChanged = false
                }

                if currentArgument.binding != argument.binding {
                    currentArgument.binding = argument.binding
                    shouldUpdateObservers = true
                }

                if currentArgument.type != argument.type {
                    currentArgument.type = argument.type
                    onlyValuesChanged = false
                } else {
                    currentArgument.value = argument.value
                }
                argumentsHaveChanged = true
                return currentArgument
            }
            argumentsHaveChanged = true
            onlyValuesChanged = false
            return KernelArgument(index: argument.index, name: argument.name, type: argument.type, value: argument.type.defaultValue, access: argument.access, origin: argument.origin)
        }
        if argumentsHaveChanged {
            currentArguments = newArguments
            if onlyValuesChanged {
                shouldUpdateCallback(.render)
            } else {
                shouldUpdateCallback(.code)
            }
        }
        if shouldUpdateObservers {
            updateDatabindingObservers()
        }
    }

    func updateDatabindingObservers() {
        // TODO: recycle observer instead of recreating
        databindingObservers.forEach { observer in
            DataBindingContext.shared.removeObserver(with: observer.argument.name)
        }
        databindingObservers.removeAll()

        for argument in currentArguments where argument.binding != nil {
            let observer = GenericDatabindingObserver(argument: argument)
            observer.didUpdateArgument = { [weak self] newArgument in
                self?.updateArgumentFromObserver(argument: newArgument)
            }
            databindingObservers.append(observer)
        }
    }

    func updateArgumentFromObserver(argument: KernelArgument) {
        currentArguments[argument.index] = argument
        shouldUpdateCallback(.render)
        addUIUpdates(newUpdates: [.update(argument.index, argument)])
    }

    func addUIUpdates(newUpdates: [KernelUIUpdate]) {
        for update in newUpdates {
            if let index = cachedUIUpdates.index(where: { (up) -> Bool in
                update.row == up.row
            }) {
                cachedUIUpdates.remove(at: index)
            }
        }
        cachedUIUpdates.append(contentsOf: newUpdates)
    }

    @objc func updateUIIfNeeded() {
        if !cachedUIUpdates.isEmpty {
            shouldUpdateCallback(.ui(cachedUIUpdates))
            cachedUIUpdates = []
        }
    }
}

//
//  KernelArgumentsController.swift
//  FilterPlayground
//
//  Created by Leo Thomas on 02.04.18.
//  Copyright © 2018 Leo Thomas. All rights reserved.
//

import Foundation

enum KernelArgumentSource {
    case code
    case ui
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

    var shouldUpdateCallback: (KernelArgumentSource) -> Void
    var kernel: Kernel
    var databindingObservers: [GenericDatabindingObserver]

    init(kernel: Kernel, shouldUpdateCallback: @escaping (KernelArgumentSource) -> Void) {
        self.shouldUpdateCallback = shouldUpdateCallback
        self.kernel = kernel
        databindingObservers = []
    }

    func updateArgumentsFromCode(arguments: [KernelDefinitionArgument]) {
        var hasChanged = arguments.count != currentArguments.count
        let newArguments = arguments.enumerated().map { (index, argument) -> KernelArgument in
            if index < currentArguments.count {
                var currentArgument = currentArguments[index]
                if currentArgument.type == argument.type {
                    if currentArgument.name != argument.name {
                        currentArgument.name = argument.name
                        hasChanged = true
                    }
                    return currentArgument
                }
            }
            hasChanged = true
            return KernelArgument(index: argument.index, name: argument.name, type: argument.type, value: argument.type.defaultValue, access: argument.access, origin: argument.origin)
        }
        if hasChanged {
            currentArguments = newArguments
            shouldUpdateCallback(.ui)
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
        shouldUpdateCallback(.ui)
    }
}

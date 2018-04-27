//
//  MainController.swift
//  FilterPlayground
//
//  Created by Leo Thomas on 10.04.18.
//  Copyright © 2018 Leo Thomas. All rights reserved.
//

import UIKit

class MainController {
    weak var attributesViewController: AttributesViewController?
    weak var liveViewController: LiveViewController?
    weak var sourceEditorViewController: SourceEditorViewController?
    weak var documentBrowser: DocumentBrowserViewController?

    var inputImageValues: [KernelInputImage] {
        get {
            return attributesViewController?.inputImages ?? []
        }

        set {
            attributesViewController?.inputImages = newValue
        }
    }

    var kernel: Kernel? {
        didSet {
            guard let kernel = kernel else {
                return
            }

            executionPipeline = KernelExecutionPipeline(kernel: kernel, errorOutput: display)
            argumentsController = KernelArgumentsController(kernel: kernel, shouldUpdateCallback: didUpdateArguments)
            attributesViewController?.extentSettings = kernel.extentSettings
            attributesViewController?.inheritSize = kernel.extent
            liveViewController?.setup(with: kernel)
        }
    }

    var executionPipeline: KernelExecutionPipeline?
    var argumentsController: KernelArgumentsController? {
        didSet {
            attributesViewController?.didUpdateArguments = argumentsController?.updateArgumentsFromUI
            attributesViewController?.didUpdatedOutputSize = didUpdatedOutputSize
            sourceEditorViewController?.didUpdateArguments = argumentsController?.updateArgumentsFromCode
        }
    }

    var project: Project?

    func display(errors: [KernelError]) {
        sourceEditorViewController?.errors = errors
        inputImageValues = inputImageValues.map { KernelInputImage(image: $0.image, index: $0.index, shouldHighlightIfMissing: $0.image == nil) }
    }

    func didOpened(document: Project) {
        let completion = {
            // TODO: Refactor!
            self.project = document
            self.sourceEditorViewController?.source = document.source
            self.attributesViewController?.arguments = document.metaData.arguments
            self.attributesViewController?.tableView.reloadData()

            let kernel = document.metaData.type.kernelClass.init()
            kernel.arguments = document.metaData.arguments
            self.kernel = kernel
            var inputImageValues = document.metaData.inputImages
            while inputImageValues.count < self.kernel!.requiredInputImages {
                inputImageValues.append(KernelInputImage(image: nil, index: inputImageValues.count, shouldHighlightIfMissing: false))
            }
            self.inputImageValues = inputImageValues
            self.sourceEditorViewController?.textView.shadingLanguage = document.metaData.type.shadingLanguage
            self.attributesViewController?.shadingLanguage = document.metaData.type.shadingLanguage
            self.attributesViewController?.supportedArguments = document.metaData.type.kernelClass.supportedArguments
            self.updateInputImages()
        }
        if let oldDocument = self.project {
            oldDocument.close(completionHandler: { _ in
                completion()
            })
        } else {
            completion()
        }
    }

    func didUpdateArguments(source: KernelArgumentSource) {
        guard let newArguments = argumentsController?.currentArguments else { return }
        switch source {
        case .code:
            sourceEditorViewController?.update(attributes: newArguments)
            break
        case let .ui(arguments):
            attributesViewController?.arguments = newArguments
            attributesViewController?.tableView.apply(changes: arguments, section: AttributesViewController.AttributesViewControllerSection.arguments.rawValue)
            break
        case .render:
            executionPipeline?.renderIfPossible()
            break
        }

        project?.metaData.arguments = newArguments
        project?.updateChangeCount(.done)
    }

    func didUpdatedOutputSize(size: KernelOutputSize) {
        project?.metaData.ouputSize = size
        kernel?.outputSize = size
        executionPipeline?.renderIfPossible()
    }

    func updateInputImages() {
        guard let project = project,
            let kernel = kernel else { return }
        kernel.inputImages = project.metaData.inputImages.compactMap { $0.image?.asCIImage }
        attributesViewController?.inheritSize = kernel.extent
        executionPipeline?.renderIfPossible()
    }

    func run() {
        guard let source = sourceEditorViewController?.source,
            let kernel = kernel,
            let project = project else {
            return
        }

        if kernel.arguments.isEmpty {
            kernel.arguments = project.metaData.arguments
        }
        executionPipeline?.execute(source: source)
    }
}

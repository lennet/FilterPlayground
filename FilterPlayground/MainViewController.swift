//
//  ViewController.swift
//  FilterPlayground
//
//  Created by Leo Thomas on 29.07.17.
//  Copyright © 2017 Leo Thomas. All rights reserved.
//

import SafariServices
import UIKit

class MainViewController: UIViewController {
    @IBOutlet var contentViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet var attributesBarButtonItem: UIBarButtonItem!
    @IBOutlet var attributesContainerWidthConstraint: NSLayoutConstraint!
    @IBOutlet var sourceEditorWidthConstraint: NSLayoutConstraint!
    weak var attributesViewController: AttributesViewController?
    weak var liveViewController: LiveViewController?
    weak var sourceEditorViewController: SourceEditorViewController?
    weak var documentBrowser: DocumentBrowserViewController?
    @IBOutlet var draggingIndicator: ViewDraggingIndicator!
    // TODO: refactor
    var inputImageValues: [KernelInputImage] {
        get {
            return attributesViewController?.inputImages ?? []
        }

        set {
            attributesViewController?.inputImages = newValue
        }
    }

    /// describe the relation between the width of the SourceEditor and the LiveView
    var sourceViewRatio: CGFloat = 0.5
    var kernel: Kernel? {
        didSet {
            guard let kernel = kernel else {
                return
            }
            attributesViewController?.extentSettings = kernel.extentSettings
            liveViewController?.setup(with: kernel)
        }
    }

    var project: Project?
    var databindingObservers: [GenericDatabindingObserver] = []

    var showAttributes = true {
        didSet {
            updateViewConstraints()
        }
    }

    override var canBecomeFirstResponder: Bool {
        return true
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        presentDocumentBrowserIfNeeded()
        registerNotifications()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    func presentDocumentBrowserIfNeeded() {
        if project == nil {
            performSegue(withIdentifier: "initialSetupSegueWithoutAnimation", sender: nil)
        }
    }

    func registerNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(applicationWillTerminate), name: NSNotification.Name.UIApplicationWillTerminate, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }

    @objc func applicationWillTerminate() {
        project?.close(completionHandler: nil)
    }

    @objc func keyboardWillShow(notification: Notification) {
        guard let keyboardSize = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else {
            return
        }
        updateBottomSpacing(animated: true, keyboardHeight: keyboardSize.height)
    }

    @objc func keyboardWillHide(notification _: Notification) {
        updateBottomSpacing(animated: true, keyboardHeight: 0)
    }

    func updateBottomSpacing(animated _: Bool, keyboardHeight: CGFloat) {
        contentViewBottomConstraint.constant = keyboardHeight
        UIView.animate(withDuration: 0.25) {
            self.view.layoutIfNeeded()
        }

        UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseInOut, animations: {
            self.view.layoutIfNeeded()
        }) { _ in
        }
    }

    override var keyCommands: [UIKeyCommand]? {
        let runKeyCommand = UIKeyCommand(input: "r", modifierFlags: .command, action: #selector(run), discoverabilityTitle: 🌎("KeyCommand_Run"))

        let increaseFontKeyCommand = UIKeyCommand(input: "+", modifierFlags: .command, action: #selector(increaseFontSize), discoverabilityTitle: 🌎("KeyCommand_IncreaseFont"))
        let increaseFontKeyCommandUSKeyboard = UIKeyCommand(input: "=", modifierFlags: .command, action: #selector(increaseFontSize))
        let decreaseFontKeyCommand = UIKeyCommand(input: "-", modifierFlags: .command, action: #selector(decreaseFontSize), discoverabilityTitle: 🌎("KeyCommand_DecreaseFont"))
        let toggleAttributesKeyCommand = UIKeyCommand(input: "0", modifierFlags: .command, action: #selector(didTapAttribtutesButton), discoverabilityTitle: showAttributes ? 🌎("KeyCommand_HideAttributes") : 🌎("KeyCommand_ShowAttributes"))

        return [runKeyCommand, increaseFontKeyCommand, increaseFontKeyCommandUSKeyboard, decreaseFontKeyCommand, toggleAttributesKeyCommand]
    }

    @objc func increaseFontSize() {
        sourceEditorViewController?.fontSize += 3
    }

    @objc func decreaseFontSize() {
        sourceEditorViewController?.fontSize -= 3
    }

    @IBAction func documentation(_ sender: UIBarButtonItem) {
        guard let url = project?.metaData.type.shadingLanguage.documentationURL else { return }
        let safariVC = SFSafariViewController(url: url)
        safariVC.modalPresentationStyle = .popover
        safariVC.popoverPresentationController?.barButtonItem = sender

        present(safariVC, animated: true, completion: nil)
    }

    @IBAction func run() {
        guard let source = sourceEditorViewController?.source,
            let kernel = kernel else {
            return
        }

        if kernel.arguments.isEmpty {
            kernel.arguments = project?.metaData.arguments ?? []
        }

        let executionPipeline = KernelExecutionPipeline(kernel: kernel, errorOutput: display)
        executionPipeline.execute(source: source)
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)

        updateViewConstraints(newWidth: size.width)
        coordinator.animate(alongsideTransition: { _ in
            self.view.layoutIfNeeded()
        }, completion: nil)
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        updateViewConstraints()
    }

    override func updateViewConstraints() {
        super.updateViewConstraints()
        updateViewConstraints(newWidth: view.frame.width)
    }

    func updateViewConstraints(newWidth: CGFloat) {
        attributesContainerWidthConstraint.constant = showAttributes ? 220 : 0
        let maxWidth = newWidth - attributesContainerWidthConstraint.constant
        sourceEditorWidthConstraint.constant = maxWidth * sourceViewRatio
    }

    func display(errors: [KernelError]) {
        sourceEditorViewController?.errors = errors
        inputImageValues = inputImageValues.map { KernelInputImage(image: $0.image, index: $0.index, shouldHighlightIfMissing: $0.image == nil) }
    }

    func didOpened(document: Project) {
        let completion = {
            // TODO: Refactor!
            self.presentedViewController?.dismiss(animated: true, completion: nil)
            self.project = document
            self.sourceEditorViewController?.source = document.source
            self.attributesViewController?.arguments = document.metaData.arguments
            self.attributesViewController?.tableView.reloadData()

            self.kernel = document.metaData.type.kernelClass.init()
            var inputImageValues = document.metaData.inputImages
            while inputImageValues.count < self.kernel!.requiredInputImages {
                inputImageValues.append(KernelInputImage(image: nil, index: inputImageValues.count, shouldHighlightIfMissing: false))
            }
            self.inputImageValues = inputImageValues
            self.showAttributes = document.metaData.type.kernelClass.supportsArguments
            self.title = document.title

            self.sourceEditorViewController?.textView.shadingLanguage = document.metaData.type.shadingLanguage
            self.attributesViewController?.shadingLanguage = document.metaData.type.shadingLanguage
            self.attributesViewController?.supportedArguments = document.metaData.type.kernelClass.supportedArguments
            self.updateInputImages()
            self.updateKernelarguments()
        }
        if let oldDocument = self.project {
            oldDocument.close(completionHandler: { _ in
                completion()
            })
        } else {
            completion()
        }
    }

    @IBAction func handleDividerPan(_ sender: UIPanGestureRecognizer) {
        let translation = sender.translation(in: sender.view!)
        sender.setTranslation(.zero, in: sender.view!)
        let maxWidth = view.frame.width - attributesContainerWidthConstraint.constant
        sourceViewRatio += translation.x / maxWidth
        sourceViewRatio = max(sourceViewRatio, 0)
        sourceViewRatio = min(sourceViewRatio, 1)

        switch sender.state {
        case .cancelled, .ended:
            let threshold: CGFloat = 100
            if sourceEditorWidthConstraint.constant < threshold {
                sourceViewRatio = 0
            } else if sourceEditorWidthConstraint.constant > (maxWidth - threshold) {
                sourceViewRatio = 1
            } else {
                fallthrough
            }
            updateViewConstraints()
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: .curveEaseInOut, animations: {
                self.view.layoutIfNeeded()
            }, completion: { _ in
                self.draggingIndicator.alwaysShowIndicator = self.sourceViewRatio == 1
                self.draggingIndicator.expandIndicator = self.sourceViewRatio == 1
            })
        default:
            draggingIndicator.alwaysShowIndicator = false
            draggingIndicator.expandIndicator = false
            updateViewConstraints()
            view.layoutIfNeeded()
        }
    }

    @IBAction func didTapAttribtutesButton() {
        showAttributes = !showAttributes
        updateViewConstraints()

        UIView.animate(withDuration: 0.25) {
            self.view.layoutIfNeeded()
        }
    }

    func didUpdateArgumentsFromAttributesViewController(onlyValueChanges: Bool) {
        guard let attributes = attributesViewController?.arguments else {
            return
        }
        project?.metaData.arguments = attributes
        project?.updateChangeCount(.done)
        if onlyValueChanges {
            updateKernelarguments()
        } else {
            sourceEditorViewController?.update(attributes: attributes)
        }
        updateDatabindingObservers()
    }

    func updateKernelarguments() {
        guard let project = project else { return }
        kernel?.arguments = project.metaData.arguments
        attributesViewController?.inheritSize = kernel?.extent ?? .zero
        kernel?.render()
    }

    func updateDatabindingObservers() {
        // TODO: recycle observer instead of recreating
        databindingObservers.forEach { observer in
            DataBindingContext.shared.removeObserver(with: observer.argument.name)
        }
        databindingObservers.removeAll()

        for argument in project?.metaData.arguments ?? [] where argument.binding != nil {
            let observer = GenericDatabindingObserver(argument: argument)
            observer.didUpdateArgument = { [weak self] newArgument in
                self?.didUpdateArgumentFromObserver(argument: newArgument)
            }
            databindingObservers.append(observer)
        }
    }

    func updateInputImages() {
        guard let project = project else { return }
        kernel?.inputImages = project.metaData.inputImages.compactMap { $0.image?.asCIImage }
        attributesViewController?.inheritSize = kernel?.extent ?? .zero
        kernel?.render()
    }

    func didUpdateArgumentFromObserver(argument: KernelArgument) {
        let currentArguments = attributesViewController?.arguments ?? []
        let newAttributes = currentArguments.map { oldArgument -> KernelArgument in
            if oldArgument.name == argument.name {
                return argument
            }
            return oldArgument
        }
        attributesViewController?.arguments = newAttributes
        project?.metaData.arguments = newAttributes
        project?.updateChangeCount(.done)
        updateKernelarguments()
    }

    func didUpdateArgumentsFromSourceEditor(arguments: [KernelDefinitionArgument]) {
        let currentAttributes = attributesViewController?.arguments ?? []
        let newAttributes = arguments.enumerated().map { (index, argument) -> KernelArgument in
            if index < currentAttributes.count {
                var currentArgument = currentAttributes[index]
                if currentArgument.type == argument.type {
                    currentArgument.name = argument.name
                    return currentArgument
                }
            }
            return KernelArgument(index: argument.index, name: argument.name, type: argument.type, value: argument.type.defaultValue, access: argument.access, origin: argument.origin)
        }
        attributesViewController?.arguments = newAttributes
        project?.metaData.arguments = newAttributes
        project?.updateChangeCount(.done)
        updateDatabindingObservers()
    }

    override func prepare(for segue: UIStoryboardSegue, sender _: Any?) {
        switch segue.destination {
        case let vc as AttributesViewController:
            attributesViewController = vc
            attributesViewController?.didUpdateAttributes = didUpdateArgumentsFromAttributesViewController
            attributesViewController?.outputSize = project?.metaData.ouputSize ?? .inherit
            attributesViewController?.inheritSize = kernel?.extent ?? .zero
            attributesViewController?.didUpdatedOutputSize = { [weak self] outputSize in
                self?.project?.metaData.ouputSize = outputSize
                self?.kernel?.outputSize = outputSize
                self?.kernel?.render()
            }
            attributesViewController?.didUpdatedImage = { [weak self] _ in
                self?.project?.metaData.inputImages = self?.inputImageValues ?? []
                self?.updateInputImages()
            }
        case let vc as LiveViewController:
            liveViewController = vc
        case let vc as SourceEditorViewController:
            sourceEditorViewController = vc
            vc.didUpdateText = { [weak self] text in
                self?.project?.source = text
            }
            vc.didUpdateArguments = didUpdateArgumentsFromSourceEditor
        case let vc as DocumentBrowserViewController:
            documentBrowser = vc
            vc.didOpenedDocument = didOpened
        default:
            print("Unkown ViewController Segue: \(segue.destination)")
        }
    }

    @IBAction func actionButtonTapped(_ sender: UIBarButtonItem) {
        var objects: [[SelectObjectViewControllerPresentable]] = [[
            ExportOption(title: 🌎("Export_CIKernel_Label"), action: exportAsCIKernel),
            ExportOption(title: 🌎("Export_CIFilter_Label"), action: exportAsCIFilter),
            ExportOption(title: 🌎("Export_SwiftPlayground_Label"), action: exportAsSwiftPlayground),
            ExportOption(title: 🌎("Export_FilterPlayground_Label"), action: exportAsPlayground),
        ]]
        var tableViewStyle: UITableViewStyle = .plain
        if (sourceEditorViewController?.errors.count ?? 0) != 0 {
            objects.insert([ExportWarningObject()], at: 0)
            tableViewStyle = .grouped
        }
        let viewController = SelectObjectController(title: "Export", objects: objects, style: tableViewStyle) { exportOption, vc in
            var senderView: UIView?
            if let selectedIndexPath = vc.tableView.indexPathForSelectedRow {
                senderView = vc.tableView.cellForRow(at: selectedIndexPath)
            }
            (exportOption as! ExportOption).action(senderView)
        }
        viewController.modalPresentationStyle = .popover
        viewController.popoverPresentationController?.barButtonItem = sender
        present(viewController, animated: true, completion: nil)
    }
}

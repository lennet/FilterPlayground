//
//  ViewController.swift
//  FilterPlayground
//
//  Created by Leo Thomas on 29.07.17.
//  Copyright © 2017 Leo Thomas. All rights reserved.
//

import UIKit
import SafariServices

class MainViewController: UIViewController {

    @IBOutlet weak var contentViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var attributesBarButtonItem: UIBarButtonItem!
    @IBOutlet weak var attributesContainerWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var sourceEditorWidthConstraint: NSLayoutConstraint!
    weak var attributesViewController: AttributesViewController?
    weak var liveViewController: LiveViewController?
    weak var sourceEditorViewController: SourceEditorViewController?
    weak var documentBrowser: DocumentBrowserViewController?

    /// describe the relation between the width of the SourceEditor and the LiveView
    var sourceViewRatio: CGFloat = 0.5
    var kernel: Kernel? {
        didSet {
            guard let kernel = kernel else {
                return
            }
            liveViewController?.setup(with: kernel)
        }
    }

    var isRunning = false

    var document: Project?
    var showLiveView = true {
        didSet {
            updateViewConstraints()
        }
    }

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
        presentDocumentBrowser()
        registerNotifications()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    func presentDocumentBrowser() {
        if document == nil {
            performSegue(withIdentifier: "initialSetupSegueWithoutAnimation", sender: nil)
        }
    }

    func registerNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(applicationWillTerminate), name: NSNotification.Name.UIApplicationWillTerminate, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }

    @objc func applicationWillTerminate() {
        document?.close(completionHandler: nil)
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

        let runKeyCommand = UIKeyCommand(input: "r", modifierFlags: .command, action: #selector(run), discoverabilityTitle: "Run")

        let increaseFontKeyCommand = UIKeyCommand(input: "+", modifierFlags: .command, action: #selector(increaseFontSize), discoverabilityTitle: "increase font size")
        let increaseFontKeyCommandUSKeyboard = UIKeyCommand(input: "=", modifierFlags: .command, action: #selector(increaseFontSize))

        let decreaseFontKeyCommand = UIKeyCommand(input: "-", modifierFlags: .command, action: #selector(decreaseFontSize), discoverabilityTitle: "decrease font size")

        return [runKeyCommand, increaseFontKeyCommand, increaseFontKeyCommandUSKeyboard, decreaseFontKeyCommand]
    }

    @objc func increaseFontSize() {
        sourceEditorViewController?.fontSize += 3
    }

    @objc func decreaseFontSize() {
        sourceEditorViewController?.fontSize -= 3
    }

    @IBAction func documentation(_ sender: UIBarButtonItem) {
        let url = URL(string: "https://developer.apple.com/library/content/documentation/GraphicsImaging/Reference/CIKernelLangRef/ci_gslang_ext.html")!
        let safariVC = SFSafariViewController(url: url)
        safariVC.modalPresentationStyle = .popover
        safariVC.popoverPresentationController?.barButtonItem = sender

        present(safariVC, animated: true, completion: nil)
    }

    @IBAction func run() {

        guard !isRunning else { return }
        defer {
            isRunning = false
        }

        guard let source = sourceEditorViewController?.source,
            let input = liveViewController?.inputImages,
            let kernel = kernel else {
            return
        }
        let attributes = attributesViewController?.attributes ?? []
        kernel.compile(source: source) { result in
            DispatchQueue.main.async {
                switch result {
                case let .success(errors: errors):
                    self.apply(kernel: kernel, input: input, attributes: attributes)
                    self.display(errors: errors)
                    break
                case let .failed(errors: errors):
                    self.display(errors: errors)
                    break
                }
            }
        }
    }

    // TODO: make function throwing to handle error handling somewhere else
    func apply(kernel: Kernel, input: [UIImage], attributes: [KernelAttribute]) {
        clearErrors()
        guard let document = document else { return }
        let requiredInputImages = document.metaData.type.kernelClass.requiredInputImages
        guard requiredInputImages == input.count else {
            display(errors: [KernelError.runtime(message: "A \(document.metaData.type) Kernel requires \(requiredInputImages) input image\(requiredInputImages > 1 ? "s" : "") but you only passed \(input.count)")])
            liveViewController?.highlightEmptyInputImageViews = true
            return
        }

        kernel.render(with: input.flatMap { $0.asCIImage }, attributes: attributes.map { $0.value.asKernelValue })
        isRunning = false
    }

    func clearErrors() {
        liveViewController?.highlightEmptyInputImageViews = false
        sourceEditorViewController?.errors = []
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
        if showLiveView {
            sourceEditorWidthConstraint.constant = maxWidth * sourceViewRatio
        } else {
            sourceEditorWidthConstraint.constant = maxWidth
        }
    }

    func display(errors: [KernelError]) {
        sourceEditorViewController?.errors = errors
        isRunning = false
    }

    func didOpened(document: Project) {
        let completion = {
            self.presentedViewController?.dismiss(animated: true, completion: nil)
            self.document = document
            self.sourceEditorViewController?.source = document.source
            self.attributesViewController?.attributes = document.metaData.attributes
            self.attributesViewController?.tableView.reloadData()
            self.liveViewController?.inputImages = document.inputImages
            self.liveViewController?.numberOfInputs = document.metaData.type.kernelClass.requiredInputImages
            self.attributesBarButtonItem.isEnabled = document.metaData.type.kernelClass.supportsArguments
            self.showAttributes = document.metaData.type.kernelClass.supportsArguments
            self.title = document.title
            self.kernel = document.metaData.type.kernelClass.init()
        }
        if let oldDocument = self.document {
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
        let oldValue = sourceViewRatio

        sourceViewRatio += translation.x / maxWidth
        sourceViewRatio = max(sourceViewRatio, 0)
        sourceViewRatio = min(sourceViewRatio, 1)

        if oldValue == 1 && sourceViewRatio < 1 {
            showLiveView = true
        }

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
            }, completion: nil)
        default:
            updateViewConstraints()
            view.layoutIfNeeded()
        }
    }

    @IBAction func didTapLiveViewButton(_: Any) {
        if showLiveView,
            sourceViewRatio == 1 {
            sourceViewRatio = 0.5
        } else if !showLiveView {
            showLiveView = true
        }
        updateViewConstraints()

        UIView.animate(withDuration: 0.25) {
            self.view.layoutIfNeeded()
        }
    }

    @IBAction func didTapAttribtutesButton(_: Any) {
        showAttributes = !showAttributes
        updateViewConstraints()

        UIView.animate(withDuration: 0.25) {
            self.view.layoutIfNeeded()
        }
    }

    func didUpdateArgumentsFromAttributesViewController(shouldRerun: Bool) {
        guard let attributes = attributesViewController?.attributes else {
            return
        }
        document?.metaData.attributes = attributes
        document?.updateChangeCount(.done)
        if shouldRerun {
            run()
        }
        sourceEditorViewController?.update(attributes: attributes)
    }

    func didUpdateArgumentsFromSourceEditor(arguments: [(String, KernelArgumentType)]) {
        let currentAttributes = attributesViewController?.attributes ?? []
        let newAttributes = arguments.enumerated().map { (index, argument) -> KernelAttribute in
            if index < currentAttributes.count {
                var currentArgument = currentAttributes[index]
                if currentArgument.type == argument.1 {
                    currentArgument.name = argument.0
                    return currentArgument
                }
            }
            return KernelAttribute(name: argument.0, type: argument.1, value: argument.1.defaultValue)
        }
        attributesViewController?.attributes = newAttributes
        document?.metaData.attributes = newAttributes
        document?.updateChangeCount(.done)
    }

    override func prepare(for segue: UIStoryboardSegue, sender _: Any?) {
        switch segue.destination {
        case let vc as AttributesViewController:
            attributesViewController = vc
            attributesViewController?.didUpdateAttributes = didUpdateArgumentsFromAttributesViewController
        case let vc as LiveViewController:
            liveViewController = vc
            vc.didUpdateInputImages = { [weak self] images in
                self?.document?.inputImages = images
            }
        case let vc as SourceEditorViewController:
            sourceEditorViewController = vc
            vc.didUpdateText = { [weak self] text in
                self?.document?.source = text
            }
            vc.didUpdateArguments = didUpdateArgumentsFromSourceEditor
        case let vc as DocumentBrowserViewController:
            documentBrowser = vc
            vc.didOpenedDocument = didOpened
        case let nc as UINavigationController where nc.viewControllers.first is ExportTableViewController:
            (nc.viewControllers.first as? ExportTableViewController)?.document = document
        default:
            print("Unkown ViewController Segue: \(segue.destination)")
        }
    }
}

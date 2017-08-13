//
//  ViewController.swift
//  FilterPlayground
//
//  Created by Leo Thomas on 29.07.17.
//  Copyright © 2017 Leo Thomas. All rights reserved.
//

import UIKit
import SafariServices

class ViewController: UIViewController {
    
    @IBOutlet weak var attributesBarButtonItem: UIBarButtonItem!
    @IBOutlet weak var attributesContainerWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var sourceEditorWidthConstraint: NSLayoutConstraint!
    weak var attributesViewController: AttributesViewController?
    weak var liveViewController: LiveViewController?
    weak var sourceEditorViewController: SourceEditorViewController?
    var isRunning = false
    
    var document: Document?
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
    
    override var keyCommands: [UIKeyCommand]? {
        
        let runKeyCommand = UIKeyCommand(input: "r", modifierFlags: .command, action: #selector(run), discoverabilityTitle: "Run")
        
        let increaseFontKeyCommand = UIKeyCommand(input: "+", modifierFlags: .command, action: #selector(increaseFontSize), discoverabilityTitle: "increase font size")
        
        let decreaseFontKeyCommand = UIKeyCommand(input: "-", modifierFlags: .command, action: #selector(decreaseFontSize), discoverabilityTitle: "decrease font size")
        
        
        return[ runKeyCommand, increaseFontKeyCommand, decreaseFontKeyCommand ]
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
            let document = document else {
                return
        }
        let attributes = attributesViewController?.attributes ?? []
        switch document.metaData.type.compile(source) {
        case .success(kernel: let kernel):
            apply(kernel: kernel, input: input, attributes: attributes)
            break
        case .failed(errors: let errors):
            display(errors: errors)
            break
        }
    }
    
    func apply(kernel: Kernel, input: [UIImage], attributes: [KernelAttribute]) {
        clearErrors()
        
        DispatchQueue.global(qos: .background).async {
            let image = kernel.apply(with: input, attributes: attributes.map{ $0.value.asKernelValue })
            
            DispatchQueue.main.async {
                self.liveViewController?.imageView.image = image
                self.isRunning = false                
            }

        }
    }
    
    func clearErrors(){
        sourceEditorViewController?.errors = []
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        updateViewConstraints(newWidth: size.width)
        coordinator.animate(alongsideTransition: { (context) in
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

        if showLiveView {
            sourceEditorWidthConstraint.constant = (newWidth - attributesContainerWidthConstraint.constant) / 2
        } else {
            sourceEditorWidthConstraint.constant = newWidth - attributesContainerWidthConstraint.constant
        }
    }
    
    func display(errors: [CompilerError]) {
        sourceEditorViewController?.errors = errors
        isRunning = false
    }
    
    func didOpened(document: Document) {
        let completion = {
            self.presentedViewController?.dismiss(animated: true, completion: nil)
            self.document = document
            self.sourceEditorViewController?.source = document.source
            self.attributesViewController?.attributes = document.metaData.attributes
            self.attributesViewController?.tableView.reloadData()
            self.liveViewController?.numberOfInputs = document.metaData.type.requiredInputImages
            self.attributesBarButtonItem.isEnabled = document.metaData.type.supportsAttributes
            self.showAttributes = document.metaData.type.supportsAttributes
            self.title = document.title
            self.liveViewController?.reset()
        }
        if let document = self.document {
            document.save(to: document.fileURL, for: .forOverwriting, completionHandler: { (_) in
                document.close(completionHandler: { (_) in
                    completion()
                })
            })
        } else {
            completion()
        }
    }
    
    @IBAction func handleDividerPan(_ sender: UIPanGestureRecognizer) {
        let translation = sender.translation(in: sender.view!)
        sender.setTranslation(.zero, in: sender.view!)
        
        let maxWidth = view.frame.width-attributesContainerWidthConstraint.constant
        
        sourceEditorWidthConstraint.constant += translation.x
        sourceEditorWidthConstraint.constant = max(sourceEditorWidthConstraint.constant, 0)
        sourceEditorWidthConstraint.constant = min(maxWidth, sourceEditorWidthConstraint.constant)
        
        switch sender.state {
        case .cancelled, .ended:
            let threshold: CGFloat = 100
            if (sourceEditorWidthConstraint.constant < threshold) {
                sourceEditorWidthConstraint.constant = 0
            } else if sourceEditorWidthConstraint.constant > (maxWidth - threshold) {
                sourceEditorWidthConstraint.constant = maxWidth
            } else {
                fallthrough
            }
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: .curveEaseInOut, animations: {
                self.view.layoutIfNeeded()
            }, completion: nil)
        default:
           view.layoutIfNeeded()
        }
    }
    
    @IBAction func didTapLiveViewButton(_ sender: Any) {
        showLiveView = !showLiveView
        updateViewConstraints()
        
        UIView.animate(withDuration: 0.25) {
            self.view.layoutIfNeeded()
        }
    }
    
    @IBAction func didTapAttribtutesButton(_ sender: Any) {
        showAttributes = !showAttributes
        updateViewConstraints()
        
        UIView.animate(withDuration: 0.25) {
            self.view.layoutIfNeeded()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.destination {
        case let vc as AttributesViewController:
            self.attributesViewController = vc
            self.attributesViewController?.didUpdateAttributes = { shouldRun in
                self.document?.metaData.attributes = self.attributesViewController?.attributes ?? []
                self.document?.updateChangeCount(.done)
                if shouldRun {
                    self.run()
                }
            }
        case let vc as LiveViewController:
            self.liveViewController = vc
        case let vc as SourceEditorViewController:
            self.sourceEditorViewController = vc
            vc.didUpdateText = { [weak self] text in
                self?.document?.source = text
            }
        case let vc as DocumentBrowserViewController:
            vc.didOpenedDocument = didOpened
        default:
            print("Unkown ViewController Segue: \(segue.destination)")
        }
    }
}


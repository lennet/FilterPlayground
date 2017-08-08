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
    
    @IBOutlet weak var liveViewWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var sourceEditorWidthConstraint: NSLayoutConstraint!
    weak var attributesViewController: AttributesViewController?
    weak var liveViewController: LiveViewController?
    weak var sourceEditorViewController: SourceEditorViewController?
    var isRunning = false
    
    var document: Document?
    var showLiveView = true
    var showAttributes = true
    
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
            let image = liveViewController?.inputImageView.image else {
                return
        }
        // todo
        let descriptor = KernelDescriptor(name: "", type: .warp, attributes: attributesViewController?.attributes ?? [])

        switch descriptor.compile(source) {
        case .success(kernel: let kernel):
            apply(kernel: kernel, input: image, attributes: descriptor.attributes)
            break
        case .failed(errors: let errors):
            display(errors: errors)
            break

        }
    }
    
    func apply(kernel: Kernel, input: UIImage, attributes: [KernelAttribute]) {
        clearErrors()
        
        DispatchQueue.global(qos: .background).async {
            let image = kernel.apply(to: input, attributes: attributes)
            
            DispatchQueue.main.async {
                self.liveViewController?.imageView.image = image
                self.isRunning = false                
            }

        }
    }
    
    func clearErrors(){
        sourceEditorViewController?.errors = []
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        updateViewConstraints()
    }
    
    override func updateViewConstraints() {
        super.updateViewConstraints()
        
        let attributesWidth: CGFloat = 220
        if showLiveView && showAttributes {
            let width = (view.frame.width - attributesWidth) / 2
            liveViewWidthConstraint.constant = width
            sourceEditorWidthConstraint.constant = width
        } else if showLiveView {
            sourceEditorWidthConstraint.constant = view.frame.width/2
            liveViewWidthConstraint.constant = view.frame.width/2
        } else if showAttributes {
            sourceEditorWidthConstraint.constant = view.frame.width-attributesWidth
            liveViewWidthConstraint.constant = 0
        } else {
            sourceEditorWidthConstraint.constant = view.frame.width
            liveViewWidthConstraint.constant = 0
        }
    }
    
    func display(errors: [CompilerError]) {
        sourceEditorViewController?.errors = errors
        isRunning = false
    }
    
    func didOpenedDocument(document: Document) {
        let completion = {
            self.presentedViewController?.dismiss(animated: true, completion: nil)
            self.document = document
            self.sourceEditorViewController?.source = document.source
            self.attributesViewController?.attributes = document.metaData.attributes
            self.attributesViewController?.tableView.reloadData()
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
            vc.didOpenedDocument = didOpenedDocument
        default:
            print("Unkown ViewController Segue: \(segue.destination)")
        }
    }
}


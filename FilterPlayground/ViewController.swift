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
    
    weak var attributesViewController: AttributesViewController? {
        didSet {
            attributesViewController?.didUpdateDescriptor = didUpdate
        }
    }
    weak var imagesViewController: ImageViewController?
    weak var sourceEditorViewController: SourceEditorViewController?
    var isRunning = false
    
    var document: Document?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
    
    func didUpdate(descriptor: KernelDescriptor, shouldRun: Bool) {
        sourceEditorViewController?.prefix = descriptor.prefix
        
        if shouldRun {
            run()
        }
    }
    @IBAction func documentation(_ sender: UIBarButtonItem) {
        let url = URL(string: "https://developer.apple.com/library/content/documentation/GraphicsImaging/Reference/CIKernelLangRef/ci_gslang_ext.html")!
        let safariVC = SFSafariViewController(url: url)
        safariVC.modalPresentationStyle = .popover
        safariVC.popoverPresentationController?.barButtonItem = sender
        
        present(safariVC, animated: true, completion: nil)
        
    }
    
    @IBAction func run() {
        
        document?.source = sourceEditorViewController?.source ?? ""
        
        guard !isRunning else { return }
        defer {
            isRunning = false
        }
        
        guard let source = sourceEditorViewController?.source,
            let image = imagesViewController?.inputImage,
            let descriptor = attributesViewController?.kernelDescriptor else {
                return
        }
        
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
        imagesViewController?.outputImage = kernel.apply(to: input, attributes: attributes)
        isRunning = false
    }
    
    func clearErrors(){
        sourceEditorViewController?.errors = []
    }
    
    func display(errors: [CompilerError]) {
        sourceEditorViewController?.errors = errors
    }
    
    func didOpenedDocument(document: Document) {
        defer {
            self.presentedViewController?.dismiss(animated: true, completion: nil)
            self.document = document
            sourceEditorViewController?.source = document.source
        }
        
        self.document?.close(completionHandler: { (status) in
            return
        })
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.destination {
        case let vc as AttributesViewController:
            self.attributesViewController = vc
        case let vc as ImageViewController:
            self.imagesViewController = vc
        case let vc as SourceEditorViewController:
            self.sourceEditorViewController = vc
        case let vc as DocumentBrowserViewController:
            vc.didOpenedDocument = didOpenedDocument
        default:
            print("Unkown ViewController Segue: \(segue.destination)")
        }
    }
}


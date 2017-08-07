//
//  DcoumentBrowserViewController.swift
//  FilterPlayground
//
//  Created by Leo Thomas on 01.08.17.
//  Copyright © 2017 Leo Thomas. All rights reserved.
//

import UIKit
import MobileCoreServices

class DocumentBrowserViewController: UIDocumentBrowserViewController, UIDocumentBrowserViewControllerDelegate {

    var didOpenedDocument: ((Document) -> ())?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.delegate = self
        allowsDocumentCreation = true
    }
    
    // MARK: UIDocumentBrowserViewControllerDelegate
    
    func documentBrowser(_ controller: UIDocumentBrowserViewController, didRequestDocumentCreationWithHandler importHandler: @escaping (URL?, UIDocumentBrowserViewController.ImportMode) -> Void) {
        let newDocumentURL = FileManager.urlInDocumentsDirectory(for: "\(Date()).CIKernel")
        
        let document = Document(fileURL: newDocumentURL)
        document.save(to: newDocumentURL, for: .forCreating) { (success) in
            if success {
                importHandler(newDocumentURL, .move)
            } else {
                importHandler(nil, .none)
            }
        }
    }
    
    func documentBrowser(_ controller: UIDocumentBrowserViewController, didPickDocumentURLs documentURLs: [URL]) {
        guard let sourceURL = documentURLs.first else { return }
        
        // Present the Document View Controller for the first document that was picked.
        // If you support picking multiple items, make sure you handle them all.
        presentDocument(at: sourceURL)
    }
    
    func documentBrowser(_ controller: UIDocumentBrowserViewController, didImportDocumentAt sourceURL: URL, toDestinationURL destinationURL: URL) {
        // Present the Document View Controller for the new newly created document
        presentDocument(at: destinationURL)
    }
    
    func documentBrowser(_ controller: UIDocumentBrowserViewController, failedToImportDocumentAt documentURL: URL, error: Error?) {
        // Make sure to handle the failed import appropriately, e.g., by presenting an error message to the user.
    }
    

    // MARK: Document Presentation
    
    func presentDocument(at documentURL: URL) {
    
        let document = Document(fileURL: documentURL)
        document.open { (_) in
            self.didOpenedDocument?(document)
        }
    
    }

}

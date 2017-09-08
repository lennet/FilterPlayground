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
        let newDocumentURL = FileManager.default.temporaryDirectory.appendingPathComponent("untitled.\(Document.type)")
        
        let tabBarController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "NewProjectTabBarController") as! UITabBarController
        let viewController = (tabBarController.viewControllers!.first as! UINavigationController).viewControllers.first as! NewProjectViewController
        let selectTemplateViewController = (tabBarController.viewControllers!.last as! UINavigationController).viewControllers.first as! SelectTemplateTableViewController
        tabBarController.modalPresentationStyle = .formSheet
        present(tabBarController, animated: true) {
            
            viewController.didSelectType = { type in
                viewController.dismiss(animated: true, completion: nil)
                let document = Document(fileURL: newDocumentURL, type: type)
                document.save(to: newDocumentURL, for: .forCreating) { (success) in
                    if success {
                        importHandler(newDocumentURL, .move)
                    } else {
                        importHandler(nil, .none)
                    }
                }
            }
            
            selectTemplateViewController.didSelectTemplate = { url in
                viewController.dismiss(animated: true, completion: nil)
                importHandler(url, .copy)
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
            if let didOpenedDocument = self.didOpenedDocument {
                didOpenedDocument(document)
            } else {
                let navigationController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "NavigationControllerIdentifier") as! UINavigationController
                let viewController = navigationController.viewControllers.first as! MainViewController
                viewController.loadViewIfNeeded()
                viewController.didOpened(document: document)
                navigationController.modalTransitionStyle = .crossDissolve
                self.present(navigationController, animated: true, completion: nil)
            }
        }
    }
    
}

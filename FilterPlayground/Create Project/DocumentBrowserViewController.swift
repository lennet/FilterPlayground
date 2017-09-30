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

    var didOpenedDocument: ((Project) -> Void)?
    var importHandler: ((URL?, UIDocumentBrowserViewController.ImportMode) -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()

        delegate = self
        allowsDocumentCreation = true
    }

    override func dismiss(animated flag: Bool, completion: (() -> Void)? = nil) {
        super.dismiss(animated: flag, completion: completion)
        importHandler?(nil, .none)
    }

    // MARK: UIDocumentBrowserViewControllerDelegate

    func documentBrowser(_: UIDocumentBrowserViewController, didRequestDocumentCreationWithHandler importHandler: @escaping (URL?, UIDocumentBrowserViewController.ImportMode) -> Void) {
        self.importHandler = importHandler
        let newDocumentURL = FileManager.default.temporaryDirectory.appendingPathComponent("untitled.\(Project.type)")

        let tabBarController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "NewProjectTabBarController") as! UITabBarController
        let viewController = (tabBarController.viewControllers!.first as! UINavigationController).viewControllers.first as! NewProjectViewController
        let selectTemplateViewController = (tabBarController.viewControllers!.last as! UINavigationController).viewControllers.first as! SelectTemplateTableViewController
        tabBarController.modalPresentationStyle = .formSheet
        present(tabBarController, animated: true) {
            viewController.didSelectType = { type in
                viewController.dismiss(animated: true, completion: nil)
                let document = Project(fileURL: newDocumentURL, type: type)
                document.save(to: newDocumentURL, for: .forCreating) { success in
                    if success {
                        importHandler(newDocumentURL, .move)
                        self.importHandler = nil
                    } else {
                        importHandler(nil, .none)
                        self.importHandler = nil
                    }
                }
            }

            selectTemplateViewController.didSelectTemplate = { url in
                viewController.dismiss(animated: true, completion: nil)
                importHandler(url, .copy)
                self.importHandler = nil
            }
        }
    }

    func documentBrowser(_: UIDocumentBrowserViewController, didPickDocumentURLs documentURLs: [URL]) {
        guard let sourceURL = documentURLs.first else { return }

        // Present the Document View Controller for the first document that was picked.
        // If you support picking multiple items, make sure you handle them all.
        presentDocument(at: sourceURL)
    }

    func documentBrowser(_: UIDocumentBrowserViewController, didImportDocumentAt _: URL, toDestinationURL destinationURL: URL) {
        // Present the Document View Controller for the new newly created document
        presentDocument(at: destinationURL)
    }

    func documentBrowser(_: UIDocumentBrowserViewController, failedToImportDocumentAt _: URL, error err: Error?) {
        // Make sure to handle the failed import appropriately, e.g., by presenting an error message to the user.
        if let error = err {
            print(error)
        }
    }

    // MARK: Document Presentation

    func presentDocument(at documentURL: URL) {

        let document = Project(fileURL: documentURL)
        document.open { _ in
            if let didOpenedDocument = self.didOpenedDocument {
                didOpenedDocument(document)
            } else if let documentViewController = self.presentingViewController as? MainViewController {
                documentViewController.didOpened(document: document)
            }
        }
    }
}

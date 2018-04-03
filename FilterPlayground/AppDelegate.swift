//
//  AppDelegate.swift
//  FilterPlayground
//
//  Created by Leo Thomas on 29.07.17.
//  Copyright © 2017 Leo Thomas. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    let documentBrowserViewController = DocumentBrowserViewController(forOpeningFilesWithContentTypes: nil)

    func application(_: UIApplication, open inputURL: URL, options _: [UIApplicationOpenURLOptionsKey: Any] = [:]) -> Bool {
        // Ensure the URL is a file URL
        guard inputURL.isFileURL else { return false }

        // Reveal / import the document at the URL
        guard let mainViewController = self.window?.rootViewController?.childViewControllers.first as? MainViewController else { return false }
        if mainViewController.documentBrowser == nil {
            mainViewController.presentDocumentBrowserIfNeeded()
        }
        //

        mainViewController.documentBrowser?.revealDocument(at: inputURL, importIfNeeded: true) { revealedDocumentURL, error in
            if let error = error {
                // Handle the error appropriately
                print("Failed to reveal the document at URL \(inputURL) with error: '\(error)'")
                return
            }
            self.documentBrowserViewController.didOpenedDocument = mainViewController.didOpened
            // Present the Document View Controller for the revealed URL
            self.documentBrowserViewController.presentDocument(at: revealedDocumentURL!)
        }

        return true
    }
}

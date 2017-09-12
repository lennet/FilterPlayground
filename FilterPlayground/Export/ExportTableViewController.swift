//
//  ExportTableViewController.swift
//  FilterPlayground
//
//  Created by Leo Thomas on 18.08.17.
//  Copyright © 2017 Leo Thomas. All rights reserved.
//

import UIKit

class ExportTableViewController: UITableViewController {

    var document: Document?

    @IBAction func tappedCancelButton() {
        dismiss(animated: true, completion: nil)
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let sender = tableView.cellForRow(at: indexPath)
        switch indexPath.row {
        case 0:
            exportAsCIKernel(sender: sender)
            break
        case 1:
            exportAsCIFIlter(sender: sender)
            break
        case 2:
            exportAsSwiftPlayground(sender: sender)
            break
        case 3:
            exportAsPlayground(sender: sender)
            break
        default:
            break
        }
    }
    
    func exportAsSwiftPlayground(sender: UIView?) {
        guard let document = document else {
            return
        }
        
        let name = document.localizedName.withoutWhiteSpaces.withoutSlash
        let inputImages = document.inputImages.flatMap(UIImagePNGRepresentation)
        let playground = SwiftPlaygroundsHelper.swiftPlayground(with: name, type: document.metaData.type, kernelSource: document.source, arguments: document.metaData.attributes, inputImages: inputImages)
        self.presentActivityViewController(sourceView: sender, items: [playground])
    }

    func exportAsPlayground(sender: UIView?) {
        guard let document = document else {
            return
        }
        document.save(to: document.fileURL, for: .forOverwriting) { _ in
            self.presentActivityViewController(sourceView: sender, items: [document.fileURL])
        }
    }
    
    func exportAsCIFIlter(sender: UIView?) {
        guard let document = document,
            let sourceData = CIFilterHelper.cifilter(with: document.source, type: document.metaData.type, arguments: document.metaData.attributes, name: document.localizedName.withoutWhiteSpaces.withoutSlash).data(using: .utf8) else {
                return
        }
        let url = FileManager.default.temporaryDirectory.appendingPathComponent("\(document.localizedName.withoutWhiteSpaces.withoutSlash).swift")
        
        do {
            try sourceData.write(to: url, options: .atomicWrite)
            
        } catch {
            print(error)
            // todo handle error
            return
        }
        presentActivityViewController(sourceView: sender, items: [url])

    }

    func exportAsCIKernel(sender: UIView?) {
        guard let document = document,
            let sourceData = document.source.data(using: .utf8) else {
            return
        }
        let url = FileManager.default.temporaryDirectory.appendingPathComponent("\(document.localizedName.withoutWhiteSpaces.withoutSlash).CIKernel")

        do {
            try sourceData.write(to: url, options: .atomicWrite)

        } catch {
            print(error)
            // todo handle error
            return
        }
        presentActivityViewController(sourceView: sender, items: [url])
    }

    func presentActivityViewController(sourceView: UIView?, items: [Any]) {
        let activityViewController = UIActivityViewController(activityItems: items, applicationActivities: nil)
        activityViewController.completionWithItemsHandler = { _, _, _, _ in
            self.dismiss(animated: true, completion: nil)
        }
        activityViewController.popoverPresentationController?.sourceView = sourceView
        present(activityViewController, animated: true, completion: nil)
    }
}
